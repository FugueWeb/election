const Election = artifacts.require("Election");

contract("Election", async (accounts) => {
  let electionInstance;

  beforeEach(async () => {
    electionInstance = await Election.new();
  });

  it("should create the contract and set proposals", async () => {
    let _proposal = await electionInstance.proposals.call(0);
    assert.equal(_proposal.name, "Proposal 1");
  });

  it("should allow admin to give another address the right to vote", async () => {
    let resultBefore = await electionInstance.proposals.call(0);
    await electionInstance.giveRightToVote(accounts[1]);
    await electionInstance.vote(0, {from: accounts[1]});
    let resultAfter = await electionInstance.proposals.call(0);
    assert.isAbove(Number(resultAfter.voteCount), Number(resultBefore.voteCount))
  });

  it("should allow an address to delegate their vote", async () => {
    await electionInstance.giveRightToVote(accounts[1]);
    await electionInstance.giveRightToVote(accounts[2]);
    await electionInstance.delegateVote(accounts[2], {from: accounts[1]});
    await electionInstance.vote(0, {from: accounts[2]});
    let resultAfter = await electionInstance.proposals.call(0);
    // let voter = await electionInstance.voters.call(accounts[3]);
    // console.log(voter);
    assert.equal(Number(resultAfter.voteCount), 2);  
  });  

  it("should allow an addr to change their vote once", async () => {
    await electionInstance.giveRightToVote(accounts[1]);
    await electionInstance.vote(0, {from: accounts[1]});
    let resultBeforeChange = await electionInstance.proposals.call(0);
    await electionInstance.changeVote(1, {from: accounts[1]});
    let resultAfterChange = await electionInstance.proposals.call(0);
    let newResult = await electionInstance.proposals.call(1);
    assert.isAbove(Number(resultBeforeChange.voteCount), Number(resultAfterChange.voteCount));
    assert.equal(Number(resultAfterChange.voteCount), 0);
    assert.equal(Number(newResult.voteCount), 1);
  });

  it("should get the proposal vote count", async () => {
    await electionInstance.giveRightToVote(accounts[1]);
    await electionInstance.vote(0, {from: accounts[1]});
    let result = await electionInstance.getProposalVoteCount(0).then(data => {
        return data;
    })
    assert.equal(Number(result), 1);
  });

  it("should check if an address has voted", async () => {
    await electionInstance.giveRightToVote(accounts[1]);
    await electionInstance.vote(0, {from: accounts[1]});
    let result = await electionInstance.hasAddressVoted(accounts[1]).then(data => {
        return data;
    })
    assert.equal(result, true);
  });

  it("should determine a winning proposal after a deadline has been met", async () => {
    await electionInstance.giveRightToVote(accounts[1]);
    await electionInstance.vote(0, {from: accounts[1]});
    let winner = await electionInstance.winnerName.call();
    console.log(winner);
    assert.equal(winner, "Proposal 1");
  });  

});
