//const Election = artifacts.require("Election");
const Elections = artifacts.require("Elections");

module.exports = function(deployer, network) {

    console.log(`${"-".repeat(30)}
    DEPLOYING Elections Contract...\n
    Using ` + network + ` network\n`);

    deployer.deploy(Elections);
};
