# Change Log

## 20210327

* Added `requestAccess` function to Elections.sol
* Updated events to show `electionID`, added `NewVoterRequest` event
* Change `VoteNFT` name to `deVoted`

## 20210314

* Created `Elections.sol` contract to allow a single smart contract to conduct multiple elections. This is linked with the `deVoted` project, see separate repo.
* Changes to various config/migration files to reflect deployment of `Elections.sol
* Created test `js` file for new contract

## 20201121

* Updated contract address for new deployment
* Changed Election.sol to include hashes of proposals, changed timestamp for new election
* Commented out `gas` and `gasPrice` fields in config file due to error on migrate

## 20201110

* Incorporated ERC721 token into `Election.sol`. When participant calls `vote` s/he receives an NFT
* Added test to `election.js` to check NFT capability
* Added `CHANGELOG.md`, pull request template, and `CONTRIBUTING.md` files
* Updated `README.md`

