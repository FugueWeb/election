## About

This project is about blockchain-based voting. Imagine a fictious election between two proposals, and registered voters may vote for one of these proposals based on whatever criteria they choose. There are also some unique capabilities in this electoral system, to include:

* Voters can opt to change their vote one time
* Voters can opt to delegate their vote to another approved voter
* Anyone can inspect in realtime the current vote count of the proposals
* Anyone can see the voting record of a given address that has voted. All voting records can be cryptographically proven.
* The election deadline is `00:00 UTC November 4, 2020`. At this time voting is no longer possible and only after can a winner can be determined.

## The Proposals

Each proposal consists of one dog and one horse. There are only two proposals. The dogs are recent *Best in Show* winners of the [Westminster Dog Show](https://en.wikipedia.org/wiki/List_of_Best_in_Show_winners_of_the_Westminster_Kennel_Club_Dog_Show), and the horses are two recent [Triple Crown](https://en.wikipedia.org/wiki/Triple_Crown_of_Thoroughbred_Racing_(United_States)) winners. Voters can choose which proposal they want based on whatever criteria they use for evaluation. Although a literal "dog and pony show", the choice is just a thought experiment to flesh out the technical use case. Don't over think it.

* Proposal 0 - Beagle + American Pharoah (colt)
* Proposal 1 - German Shorthaired Pointer + Justify (stallion)

|Proposal 0 | Proposal 1 |
|:---------:|:----------:|
|![Beagle](https://upload.wikimedia.org/wikipedia/commons/b/b7/Tashtins_Lookin_For_Trouble.jpg?thumbnail)   |![German Shorthaired Pointer](https://upload.wikimedia.org/wikipedia/commons/8/84/CJ_Westminister_Winner_2016_Garbonita.jpg?thumbnail) |
|![American Pharoah](https://multifiles.pressherald.com/uploads/sites/4/2015/05/Preakness-Stakes-Hors_Beau-1024x726.jpg?thumbnail) |![Justify](https://visithorsecountry.com/wp-content/uploads/2018/05/Justify-at-hopewell-oct-2016-1024x811.jpg?thumbnail)   |

## How to Use

You can either read information from the smart contract, or write to the smart contract. Reading is possible for anyone and requires no special setup. Writing, however, requires making state changes to the blockchain and certain access roles, and thus voter registration as well as a way to interact with a blockchain are necessary.

### Read from the Contract

Use [this link](https://ropsten.etherscan.io/address/0x7b5647e019835438f8435c7b2a9258d85d290ca5#readContract) to go to the Etherscan block explorer for the smart contract. There are many things you can see here relative to the history of the smart contract. Likely the main items of interest are seeing the current state of the `proposals` and the `voters`.

* `proposals` - Scroll down and enter either `0` or `1` into block #11. There are only two valid proposal IDs (see Proposals section above) and so any other numbers entered will throw an error. Entering a valid proposal number will return the `name` of the proposal as well as the current `voteCount`.
* `voters` - Scroll down to block #12 and enter a valid Ethereum address. An example address of a registered voter is `0x5632aB6622614bc3eB4AeA5e04f431784d9E4D60`. This will return the following properties.
    * `weight` - If the address has been granted voting rights, the weight will be `1`. This value can be greater than 1 only if a voter has delegated their vote to another address and that address has not yet voted.
    * `voted` - Returns `true` if the address has already voted or delegated their vote.
    * `hasChangedVote` - Returns `true` if the address has changed their vote. Voters may only change their vote once.
    * `delegate` - Address delegated to. If `0x0000000000000000000000000000000000000000` that means the voter has not delegated.
    * `vote` - Proposal number that the address voted for. Note, the default for someone who has not yet voted is `0`, so this value only means a vote for Proposal #0 if `voted` is also `true`.
* `Events` - Events are emitted by a smart contract when certain state changes occur. You can see past [events here](https://ropsten.etherscan.io/address/0x7b5647e019835438f8435c7b2a9258d85d290ca5#events), which include information for when voters were registered and when voters either voted or changed their vote.

### Write to the Contract

This requires some setup so please first follow these steps carefully.

1. Install the [Metamask](https://metamask.io/) browser extension (into Chrome, Firefox, or Brave) and follow steps to setup and backup your wallet. Although a simple browser extension, you should only install Metamask on a laptop/computer *that you personally own* or on one for which you have been *given explicit permission*.
2. After installation, you should see a fox icon (i.e., the Metamask extension) in the top right of your browser. Click the icon and change the network (drop down menu, top center) to `Ropsten`.
3. Email your Ethereum address to the project coordinator, or paste it into [this issue](https://github.com/FugueWeb/election/issues/1). This is the basic equivalent of voter registration. If you open Metamask, you can copy your address by clicking where it says `Account 1`. Note, if you have previously participated in a blockchain workshop run by the coordinator, you have already been registered.
    * You can confirm that the voter role has been granted to you by following [this link](https://ropsten.etherscan.io/address/0x7b5647e019835438f8435c7b2a9258d85d290ca5#readContract), copying the bytes32 variable in `#4 VOTER_ROLE` and pasting it along with your address in `#10 hasRole` and clicking `Query`. If you have been granted the role, it will return `true`.
4. To make state changes on the Ethereum blockchain you need to pay transaction fees, and for that you need `ether`. If you do not have any `Ropsten` test ether (you can see your balance in Metamask), you can go to [this faucet](https://faucet.ropsten.be/) and paste in your address to request some for free.
5. You are now ready to interact with the smart contract. Follow [this link](https://ropsten.etherscan.io/address/0x7b5647e019835438f8435c7b2a9258d85d290ca5#writeContract) to go to the Etherscan block explorer. On the left side, you should see a red dot and a link that says `Write Contract Connect to Web3`. Click the link and approve the prompts to allow Metamask to interact with the block explorer.

* `vote` - Block #7 is where you can cast your vote. You can enter either `0` or `1`, depending on your choice between the proposals.
* `changeVote` - Block #1 is where you can change your vote if you have already voted. You may only do this once, you must have already voted, and you must not have delegated your vote.
* `delegateVote` - Block #2 is where you can delegate another address to vote on your behalf. You may not delegate your vote to someone else if you have already voted. The delegate address must also be an approved voter, which you can confirm by following the instructions listed above in step #3. If the delegate address has already voted, the proposal they voted for is immediately incremented by one. If the delegate address has not yet voted, their vote weight is incremented by one.
* `giveRightToVote` and `grantRole` - Blocks #3 and #4 can only be called by an admin. These are the means by which the smart contract admins are able to essentially register addresses to vote.

## Troubleshooting

* Ensure Metamask is unlocked and on the `Ropsten` test network
* Ensure that you have sufficient funds to send transactions. You can get free test ether by request using [a faucet](https://faucet.ropsten.be/)
* If you are using Brave browser and are getting an error on Etherscan saying Web3 is not detected, go into your Brave Settings -> Extensions -> Set your Web3 provider to Metamask
* Ensure that you have approved Metamask to access Etherscan. You can check this by opening Metamask and going into Settings -> Connections. You should see `ropsten.etherscan.io` listed under "Connected". If it's not, add it. If it is already there, try removing and re-adding it. Then try step #5 again.
* If your transactions are failing, try raising the `gas fee` to "fast"
* If your transactions continue to fail, they may be unauthorized. You can check whether you have appropriate voting roles by following step #3 above, or by checking the state of your address following steps under "Read from the Contract"

## Discussion

* What are some of the ramifications of allowing voter delegation?
    * Should there be a limit on the number of delegate votes a voter can receive?
* Assuming this type of model introduces improvements to a status quo electoral system (i.e., ease of voting, improved transparency, higher turnout), why might a power structure *not* want it to succeed?
* What are some concerns about the voter registration process? Consider this in light of a permissioned blockchain versus a public, decentralized blockchain (similar to intranet vs internet).

## Resources

* [US Postal Service Files Blockchain Voting Patent](https://cointelegraph.com/news/us-postal-service-files-blockchain-voting-patent-following-trump-cuts)
    * [Patent](https://pdfaiw.uspto.gov/.aiw?docid=20200258338&PageNum=32&IDKey=7A4F4EA40D1F)
    > “A voting system can use the security of blockchain and the mail to provide a reliable voting system. A registered voter receives a computer-readable code in the mail and confirms identity and confirms correct ballot information in an election. The system separates voter identification and votes to ensure vote anonymity, and stores votes on a distributed ledger in a blockchain.”
* [MakerDAO](https://twitter.com/MakerDAO/status/1294326266879815685)