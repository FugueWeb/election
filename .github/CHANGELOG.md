# Change Log

## 20201110

* Incorporated ERC721 token into `Election.sol`. When participant calls `vote` s/he receives an NFT
* Added test to `election.js` to check NFT capability
* Added `CHANGELOG.md`, pull request template, and `CONTRIBUTING.md` files
* Updated `README.md`

## 20201121

* Updated contract address for new deployment
* Changed Election.sol to include hashes of proposals, changed timestamp for new election
* Commented out `gas` and `gasPrice` fields in config file due to error on migrate