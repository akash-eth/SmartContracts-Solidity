const SimpleSmartContract = artifacts.require("SimpleSmartContract.sol");

module.exports = function(deployer) {
    deployer.deploy(SimpleSmartContract);
} 