## About

This project is about blockchain-based voting. Imagine a fictious election between two proposals, and authorized participants may vote on one of these proposals based on whatever criteria they choose. Other capabilities include:

* Voters can opt to change their vote one time
* Voters can opt to delegate their vote to another approved voter
* Anyone can inspect in realtime the current vote count of the proposals, as well as the votes of other participants
* The election deadline is `00:00 UTC November 4, 2020`. At this time voting is no longer possible and a winner can be determined.

## The Candidates

Each candidacy consists of a dog and a horse. The dogs are recent *Best in Show* winners of the [Westminster Dog Show](https://en.wikipedia.org/wiki/List_of_Best_in_Show_winners_of_the_Westminster_Kennel_Club_Dog_Show), and the horses are two recent [Triple Crown](https://en.wikipedia.org/wiki/Triple_Crown_of_Thoroughbred_Racing_(United_States)) winners.

* Proposal 0 - Beagle and American Pharoah (colt)
* Proposal 1 - German Shorthaired Pointer and Justify (stallion)

|Proposal 0 | Proposal 1 |
|:---------:|:----------:|
|![Beagle](https://upload.wikimedia.org/wikipedia/commons/b/b7/Tashtins_Lookin_For_Trouble.jpg?thumbnail)   |![German Shorthaired Pointer](https://upload.wikimedia.org/wikipedia/commons/8/84/CJ_Westminister_Winner_2016_Garbonita.jpg?thumbnail) |
|![American Pharoah](https://multifiles.pressherald.com/uploads/sites/4/2015/05/Preakness-Stakes-Hors_Beau-1024x726.jpg?thumbnail) |![Justify](https://visithorsecountry.com/wp-content/uploads/2018/05/Justify-at-hopewell-oct-2016-1024x811.jpg?thumbnail)   |

## How to Use

You can either read information from the smart contract, or write to the contract. Reading is possible for anyone, whereas writing requires making state changes to the blockchain and certain access roles.

### Read from the Contract

Use this [link](https://ropsten.etherscan.io/address/0x7b5647e019835438f8435c7b2a9258d85d290ca5#readContract) to go to the Etherscan block explorer for the smart contract. The main items of interest are seeing the current state of `proposals` and `voters`.

* `proposals` - Scroll down and enter either `0` or `1` into block #11. There are only two proposals (see Candidates above) and any other numbers entered will throw an error. Otherwise, entering a valid proposal number will return the `name` of the proposal as well as the current `voteCount`.
* `voters` - Scroll down to block #12 and enter a valid Ethereum address. This will return the following properties.
    * `weight` - If the address has been granted voting rights, the weight will be `1`. This value can be higher only if a voter has delegated their vote to another address and that address has not yet voted.
    * `voted` - Returns `true` if the address has already voted or delegated their vote.
    * `hasChangedVote` - Returns `true` if the address has changed their vote. Voters may only change their vote once.
    * `delegate` - Address delegated to. If `0x0000000000000000000000000000000000000000` that means the address has not delegated.
    * `vote` - Proposal number that the address voted for. Note, the default is `0` but this only means the address voted for proposal 0 if `voted` is also set to `true`.

### Write to the Contract

This requires some setup so please first follow these steps carefully.

1. Install the [Metamask](https://metamask.io/) browser extension and follow steps to setup your wallet.
2. You should see a fox icon (Metamask) in the top right of your browser. Click the fox icon and change the network (drop down menu in the top center) to `Ropsten`.
2. Find and provide your Ethereum address to the project's coordinator. This is the equivalent of voter registration. If you open Metamask, you can copy the address by clicking where it says `Account 1`. 
    * You can confirm that the voter role has been granted to you by following [this link](https://ropsten.etherscan.io/address/0x7b5647e019835438f8435c7b2a9258d85d290ca5#readContract), copying the bytes32 variable in `#4 VOTER_ROLE` and pasting it along with your address in `#10 hasRole` and clicking `Query`. If you have been granted the role, it will return `true`.
3. To make state changes on the Ethereum blockchain you need to pay transaction fees, and for that you need `ether`. If you do not have any `Ropsten` test ether, you can go to [this faucet](https://faucet.ropsten.be/) and paste in your address to request some for free.
4. You are now ready to interact with the smart contract. Follow this [link](https://ropsten.etherscan.io/address/0x7b5647e019835438f8435c7b2a9258d85d290ca5#writeContract) to go to the Etherscan block explorer. You should see a red dot and `Write Contract Connect to Web3`. Click the `Connect to Web3` link and approve the prompts to allow Metamask to interact with the block explorer. As mentioned before, make sure you are on the `Ropsten` network.

* `vote` - Block #7 is where you can cast your vote. You can enter either `0` or `1`, depending on your choice between the candidates.
* `changeVote` - Block #1 is where you can change your vote if you have already voted. You may only do this once, you must have already voted, and you must not have delegated your vote.
* `delegateVote` - Block #2 is where you can delegate another address to vote on your behalf. The delegate address must also be an approved voter, and you can check this by following the instructions listed above in step #2. If the delegate address has already voted, the candidate they voted for is immediately incremented by one. If the delegate address has not yet voted, their vote weight is incremented by one.
* `giveRightToVote` and `grantRole` - Blocks #3 and #4 can only be called by an admin. These are the means by which the smart contract admins are able to essentially register addresses to vote.
