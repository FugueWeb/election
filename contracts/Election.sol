pragma solidity ^0.6.0;

import "../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../node_modules/@openzeppelin/contracts/GSN/Context.sol";
import "../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "./VoteNFT.sol";

contract Election is Context, AccessControl, VoteNFT {
    using SafeMath for uint256;
    uint public constant ELECTION_DEADLINE = 1605092400; //1604448000
    string constant TOKEN_URI = "https://ropsten.etherscan.io/tx/";

    // OZ access control
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant VOTER_ROLE = keccak256("VOTER_ROLE");

    // Events
    event Voted(uint propNumber, address indexed voter, uint256 newNFT);
    event ChangedVote(uint propNumber, address indexed voter);

    struct Voter {
        uint weight; // weight is accumulated by delegation
        bool voted;  // if true, that person already voted
        bool hasChangedVote; // user can change vote only once
        address delegate; // person delegated to
        uint vote;   // index of the voted proposal
    }

    struct Proposal {
        string name;   // short name
        uint voteCount; // number of accumulated votes
    }

    // stores a `Voter` struct for each possible address.
    mapping(address => Voter) public voters;

    // A dynamically-sized array of `Proposal` structs.
    Proposal[] public proposals;

    /// Create a new ballot to choose one of `proposalNames`.
    constructor() public {
        _setupRole(ADMIN_ROLE, _msgSender());
        _setupRole(VOTER_ROLE, _msgSender());
        voters[_msgSender()].weight = 1;

        proposals.push(Proposal({name: "Beagle-AP", voteCount: 0}));
        proposals.push(Proposal({name: "Pointer-J", voteCount: 0}));
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
     * @dev Give `voter` the right to vote on this ballot.
     * @param voter address to grant voting access
     */
    function giveRightToVote(address voter) public onlyAdmin {
        require(!voters[voter].voted, "Address has already voted");
        voters[voter].weight = 1;
        _setupRole(VOTER_ROLE, voter);
    }

    /**
     * @dev Delegate to `to` the weight of another valid voter's vote
     * @param to delegate address
     */
    function delegateVote(address to) public onlyVoter {
        // Check that addr delegate has right to vote
        require(hasRole(VOTER_ROLE, to), "DOES_NOT_HAVE_VOTER_ROLE");

        Voter storage sender = voters[_msgSender()];
        require(!sender.voted, "Address has already voted");

        // Forward the delegation if `to` also delegated.
        while (voters[to].delegate != address(0) &&
            voters[to].delegate != _msgSender()) {
            to = voters[to].delegate;
        }

        require(to != _msgSender(), "Delegation can not be to self");

        // Update `sender`
        sender.voted = true;
        sender.delegate = to;

        Voter storage delegate = voters[to];
        if (delegate.voted) {
            // If delegate already voted, directly add to the number of votes
            proposals[delegate.vote].voteCount += sender.weight;
            // Add sender weight to delegate as well in case delegate changes vote
            delegate.weight += sender.weight;
            emit Voted(delegate.vote, _msgSender(), 0); //not rewarding NFT for delegation
        } else {
            // If delegate did not vote yet, add to weight.
            delegate.weight += sender.weight;
        }
    }

    /**
     * @dev Vote on a given proposal
     * @param proposal number of proposal
     */
    function vote(uint proposal) public onlyVoter {
        require(now < ELECTION_DEADLINE, "Voting deadline has expired");
        Voter storage sender = voters[_msgSender()];
        require(!sender.voted, "Address has already voted");
        // Only two choices in the election
        require(proposal < 2, "Invalid proposal number");

        sender.voted = true;
        sender.vote = proposal;

        proposals[proposal].voteCount += sender.weight;
        //Reward proposer with NFT
        uint256 NFT_ID = awardItem(_msgSender(), TOKEN_URI);
        emit Voted(proposal, _msgSender(), NFT_ID);
    }

    /**
     * @dev Change your vote to a different proposal, may only be executed once per user
     * @param proposal number of proposal, must not be same as previous vote
     */
    function changeVote(uint proposal) public onlyVoter {
        Voter storage sender = voters[_msgSender()];
        require(sender.voted, "Address must have already voted");
        require(!sender.hasChangedVote, "Voter can only change vote once");
        require(proposal < 2, "Invalid proposal number");
        require(sender.vote != proposal, "New proposal is same as current vote");
        require(sender.delegate == address(0), "Voter must not have delegated");
        //require(sender.weight == 1, "Delegates may not change vote"); Uncomment if applicable

        // Remove vote from old proposal
        uint oldProposal = sender.vote;
        proposals[oldProposal].voteCount -= sender.weight;

        // Add vote to new proposal
        sender.vote = proposal;
        proposals[proposal].voteCount += sender.weight;
        sender.hasChangedVote = true;
        emit ChangedVote(proposal, _msgSender());
    }

    /**
     * @dev Computes then returns the winning proposal, taking all previous votes into account.
     */
    function winningProposal() internal view returns (uint) {
        uint winningVoteCount = 0;
        uint wProposal;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                wProposal = p;
            }
        }
        return wProposal;
    }

    /**
     * @dev Calls winningProposal() function to get the index of winner and then returns the name
     */
    function winnerName() public view returns (string memory) {
        require(now > ELECTION_DEADLINE, "Have not reached election deadline");
        return proposals[winningProposal()].name;
    }

    /**
     * @dev Gets current vote count of a given proposal
     * @return uint current vote count
     */
    function getProposalVoteCount(uint proposal) public view returns (uint) {
        return proposals[proposal].voteCount;
    }

    /**
     * @dev Check if a given address has voted
     * @return bool has the address voted
     */
    function hasAddressVoted(address voter) public view returns (bool) {
        return voters[voter].voted;
    }
}