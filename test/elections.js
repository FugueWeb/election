const Elections = artifacts.require("Elections");
const eid = 1;
const timestamp = 1616272283; // March 20
const prop0 = 0;
const prop1 = 1;

contract("Elections", async (accounts) => {
    let electionInstance;

    beforeEach(async () => {
        electionInstance = await Elections.new();
    });

    it("should allow admin to create a new election", async () => {
        let e = await electionInstance.newElection("prop0", "prop1", timestamp);
        console.log(e.logs[0].args);
    });

    it("should allow admin to create new election, register new voter, and allow new voter to vote", async () => {
        let account_one = accounts[0];
        let account_two = accounts[1];
        let instance = await Elections.deployed();
        await instance.newElection("prop0", "prop1", timestamp);
        await instance.registerToVote(account_two);
        await instance.registerForElection(eid, {from: account_two});
        let result = await instance.vote(prop0, eid, {from: account_two}); // voter votes
        assert.equal(Number(result.logs[0].args[2]), 1); //NFT issued
        let count = await instance.getProposalVoteCount.call(prop0, eid);
        assert.equal(count.toNumber(), 1);
        await instance.vote(prop0, eid, {from: account_one}); //admin votes
        let count2 = await instance.getProposalVoteCount.call(prop0, eid);
        assert.equal(count2.toNumber(), 2);
    });

    it("should allow an address to delegate their vote", async () => {
        let account_three = accounts[2];
        let account_four = accounts[3];
        let instance = await Elections.deployed();
        await instance.newElection("prop0", "prop1", timestamp);
        await instance.registerToVote(account_three);
        await instance.registerToVote(account_four);
        await instance.registerForElection(eid, {from: account_three}); //register for election
        await instance.delegateVote(account_four, eid, {from: account_three}); //delegate vote
        let hasDelegated = await instance.hasAddressVoted.call(account_three, eid);
        assert.isTrue(hasDelegated);

        await instance.registerForElection(eid, {from: account_four}); //register for election
        await instance.vote(prop0, eid, {from: account_four});

        let info = await instance.getVoterInfo.call(eid, account_three);
        console.log(info);
        let info2 = await instance.getVoterInfo.call(eid, account_four);
        console.log(info2);
        // let count = await instance.getProposalVoteCount.call(prop0, eid);
        // assert.equal(count.toNumber(), 1);
    });

    // it("should allow an addr to change their vote once", async () => {
    //     await electionInstance.registerToVote(accounts[1]);
    //     await electionInstance.vote(0, {
    //         from: accounts[1]
    //     });
    //     let resultBeforeChange = await electionInstance.proposals.call(0);
    //     await electionInstance.changeVote(1, {
    //         from: accounts[1]
    //     });
    //     let resultAfterChange = await electionInstance.proposals.call(0);
    //     let newResult = await electionInstance.proposals.call(1);
    //     assert.isAbove(Number(resultBeforeChange.voteCount), Number(resultAfterChange.voteCount));
    //     assert.equal(Number(resultAfterChange.voteCount), 0);
    //     assert.equal(Number(newResult.voteCount), 1);
    // });

    // it("should get the proposal vote count", async () => {
    //     await electionInstance.registerToVote(accounts[1]);
    //     await electionInstance.vote(0, {
    //         from: accounts[1]
    //     });
    //     let result = await electionInstance.getProposalVoteCount(0).then(data => {
    //         return data;
    //     })
    //     assert.equal(Number(result), 1);
    // });

    // it("should check if an address has voted", async () => {
    //     await electionInstance.registerToVote(accounts[1]);
    //     await electionInstance.vote(0, {
    //         from: accounts[1]
    //     });
    //     let result = await electionInstance.hasAddressVoted(accounts[1]).then(data => {
    //         return data;
    //     })
    //     assert.equal(result, true);
    // });

    // it("should determine a winning proposal after a deadline has been met", async () => {
    //     await electionInstance.registerToVote(accounts[1]);
    //     await electionInstance.registerToVote(accounts[2]);
    //     await electionInstance.registerToVote(accounts[3]);
    //     await electionInstance.vote(1, {
    //         from: accounts[1]
    //     });
    //     await electionInstance.vote(0, {
    //         from: accounts[2]
    //     });
    //     await electionInstance.vote(0, {
    //         from: accounts[3]
    //     });
    //     let winner = await electionInstance.winnerName.call();
    //     console.log(winner);
    //     assert.equal(winner, "Beagle-AP");
    // });

});
