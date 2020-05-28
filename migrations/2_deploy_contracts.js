const Election = artifacts.require("Election");

module.exports = function(deployer, network) {

    console.log(`${"-".repeat(30)}
    DEPLOYING Election Contract...\n
    Using ` + network + ` network\n`);

    deployer.deploy(Election);
};
