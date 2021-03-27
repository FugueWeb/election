pragma solidity ^0.6.0;

import "../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../node_modules/@openzeppelin/contracts/GSN/Context.sol";
import "../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "./VoteNFT.sol";

contract Elections is Context, AccessControl, VoteNFT {
    using SafeMath for uint256;
    string constant TOKEN_URI = "https://ropsten.etherscan.io/tx/";
    uint internal electionCount;

    // OpenZeppelin access control
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant VOTER_ROLE = keccak256("VOTER_ROLE");

    // Events
    event NewElection(uint eid, uint deadline);
    event VoterRegistered(address indexed registeredVoter, uint electionID);
    event NewVoterRequest(address indexed newVoter);
    event Voted(uint propNumber, uint eid, address indexed voter, uint256 newNFT);
    event Delegated(address indexed delegate, uint eid, address indexed voter);
    event ChangedVote(uint propNumber, uint eid, address indexed voter);

    struct Voter {
        uint weight; // weight is accumulated by delegation
        bool voted;  // if true, that person already voted
        bool registered; // need to register for each election
        bool hasChangedVote; // user can change vote only once
        address delegate; // person delegated to
        uint vote;   // index of the voted proposal
    }

    struct Proposal {
        string name;   // short name
        uint voteCount; // number of accumulated votes
    }

    struct Election {
        mapping(address => Voter) voters;
        Proposal[] proposals;
        uint deadline;
    }

    // stores an `Election` struct to an election ID
    mapping(uint => Election) public elections;

    // Assign admin and voter role to msg.sender
    constructor() public {
        _setupRole(ADMIN_ROLE, _msgSender());
        _setupRole(VOTER_ROLE, _msgSender());
        _setRoleAdmin(VOTER_ROLE, ADMIN_ROLE); //sets admin role in charge of voter role
    }

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, _msgSender()), "DOES_NOT_HAVE_ADMIN_ROLE");
        _;
    }

    modifier onlyVoter() {
        require(hasRole(VOTER_ROLE, _msgSender()), "DOES_NOT_HAVE_VOTER_ROLE");
        _;
    }

    /**
     * @dev Admin creates new election with two competing proposals
     * @param proposal1 string or hash describing proposal or candidate
     * @param proposal2 string or hash describing proposal or candidate
     */
    function newElection(string memory proposal1, string memory proposal2, uint dl) public onlyAdmin {
        uint electionID = electionCount + 1;
        Election storage e = elections[electionID];
        e.voters[_msgSender()].weight = 1;
        e.voters[_msgSender()].registered = true;
        e.proposals.push(Proposal({name: proposal1, voteCount: 0}));
        e.proposals.push(Proposal({name: proposal2, voteCount: 0}));
        e.deadline = dl;
        emit NewElection(electionID, dl);
        electionCount++;
    }

    /**
     * @dev Public function allowing users to request for admin to register their address
     */
    function requestAccess() public {
        require(!hasRole(VOTER_ROLE, _msgSender()), "ALREADY_HAS_VOTER_ROLE");
        emit NewVoterRequest(_msgSender());
    }

    /**
     * @dev Give `voter` the right to vote and register for elections
     * @param voter address to grant voting access
     */
    function registerToVote(address voter) public onlyAdmin {
        require(!hasRole(VOTER_ROLE, voter), "ALREADY_HAS_VOTER_ROLE");
        _setupRole(VOTER_ROLE, voter);
    }

    /**
     * @dev Revoke registered `voter` from participating in elections
     * @param voter address being revoked voting access
     */
    function revokeVoter(address voter) public onlyAdmin {
        require(hasRole(VOTER_ROLE, voter), "VOTER_MUST_ALREADY_HAVE_ROLE");
        revokeRole(VOTER_ROLE, voter);
    }

    /**
     * @dev Voter with `VOTER_ROLE` self registers for a given election
     * @param electionID ID for the election the voter wants to vote in
     */
    function registerForElection(uint electionID) public onlyVoter {
        Election storage e = elections[electionID];
        require(!e.voters[_msgSender()].registered, "VOTER_ALREADY_REGISTERED");
        require(block.timestamp < e.deadline, "Voting deadline has expired");
        e.voters[_msgSender()].weight += 1;
        e.voters[_msgSender()].registered = true;
        emit VoterRegistered(_msgSender(), electionID);
    }

    /**
     * @dev Delegate to `to` the weight of another valid voter's vote
     * @param to delegate address
     * @param electionID ID of election in which voter is delegating their vote
     */
    function delegateVote(address to, uint electionID) public onlyVoter {
        // Check that addr delegate has right to vote
        require(hasRole(VOTER_ROLE, to), "DOES_NOT_HAVE_VOTER_ROLE");
        Election storage e = elections[electionID];

        Voter storage sender = e.voters[_msgSender()];
        require(!sender.voted, "Address has already voted");

        // Forward the delegation if `to` also delegated.
        while (e.voters[to].delegate != address(0) &&
            e.voters[to].delegate != _msgSender()) {
            to = e.voters[to].delegate;
        }

        require(to != _msgSender(), "Delegation can not be to self");

        // Update `sender`
        sender.voted = true;
        sender.delegate = to;

        Voter storage delegate = e.voters[to];
        if (delegate.voted) {
            // If delegate already voted, directly add to the number of votes
            e.proposals[delegate.vote].voteCount += sender.weight;
            // Add sender weight to delegate as well in case delegate changes vote
            delegate.weight += sender.weight;
            // Emit `Voted` event since Delegate has already voted; no NFT rewarded for delegation
            emit Voted(delegate.vote, electionID, _msgSender(), 0); 
        } else {
            // If delegate did not vote yet, add to weight.
            delegate.weight += sender.weight;
            emit Delegated(sender.delegate, electionID, _msgSender());
        }
    }

    /**
     * @dev Vote on a given proposal
     * @param proposal number of proposal
     * @param electionID ID of election in which voter is delegating their vote
     */
    function vote(uint proposal, uint electionID) public onlyVoter {
        // Only two choices in the election
        require(proposal < 2, "Invalid proposal number");
        Election storage e = elections[electionID];
        require(block.timestamp < e.deadline, "Voting deadline has expired");
        Voter storage sender = e.voters[_msgSender()];
        require(!sender.voted, "Address has already voted");
        require(sender.registered, "Voter must register for each election");
        
        sender.voted = true;
        sender.vote = proposal;

        e.proposals[proposal].voteCount += sender.weight;
        //Reward proposer with NFT
        uint256 NFT_ID = awardItem(_msgSender(), TOKEN_URI);
        emit Voted(proposal, electionID, _msgSender(), NFT_ID);
    }

    /**
     * @dev Change your vote to a different proposal, may only be executed once per user
     * @param proposal number of proposal, must not be same as previous vote
     * @param electionID ID of election in which voter is delegating their vote
     */
    function changeVote(uint proposal, uint electionID) public onlyVoter {
        // Only two choices in the election
        require(proposal < 2, "Invalid proposal number");
        Election storage e = elections[electionID];

        Voter storage sender = e.voters[_msgSender()];
        require(sender.voted, "Address must have already voted");
        require(!sender.hasChangedVote, "Voter can only change vote once");
        require(sender.vote != proposal, "New proposal is same as current vote");
        require(sender.delegate == address(0), "Voter must not have delegated");
        //require(sender.weight == 1, "Delegates may not change vote"); Uncomment if applicable

        // Remove vote from old proposal
        uint oldProposal = sender.vote;
        e.proposals[oldProposal].voteCount -= sender.weight;

        // Add vote to new proposal
        sender.vote = proposal;
        e.proposals[proposal].voteCount += sender.weight;
        sender.hasChangedVote = true;
        emit ChangedVote(proposal, electionID, _msgSender());
    }

    /**
     * @dev Computes then returns the winning proposal, taking all previous votes into account.
     * @param electionID ID of election
     */
    function winningProposal(uint electionID) internal view returns (uint) {
        Election storage e = elections[electionID];
        // uint winningVoteCount = 0;
        // uint wProposal;
        uint prop0 = e.proposals[0].voteCount;
        uint prop1 = e.proposals[1].voteCount;
        if (prop0 > prop1){
            return 0; 
        } else if (prop1 > prop0) {
            return 1;
        } else { // it's a tie
            return 2;
        }
    }

    /**
     * @dev Calls winningProposal() function to get the index of winner and then returns the name
     * @param electionID ID of election
     */
    function winnerName(uint electionID) public view returns (string memory) {
        Election storage e = elections[electionID];
        require(block.timestamp > e.deadline, "Have not reached election deadline");
        uint result = winningProposal(electionID);
        if (result != 2) {
            return e.proposals[result].name;
        } else {
            return "TIE";
        }
    }

    /**
     * @dev Gets current state of a voter
     * @return uint TODO
     * @param electionID ID of election
     * @param voter voter address
     */
    function getVoterInfo(uint electionID, address voter) public view returns (uint, bool, bool, bool, address, uint) {
        Election storage e = elections[electionID];
        return (e.voters[voter].weight, e.voters[voter].voted, e.voters[voter].registered,
        e.voters[voter].hasChangedVote, e.voters[voter].delegate, e.voters[voter].vote);
    }

    /**
     * @dev Gets current state of an election
     * @return uint TODO
     * @param electionID ID of election
     */
    function getElectionInfo(uint electionID) public view returns (string memory, uint, string memory, uint, uint) {
        Election storage e = elections[electionID];
        return (e.proposals[0].name, e.proposals[0].voteCount, 
        e.proposals[1].name, e.proposals[1].voteCount, e.deadline);
    }
}