var Bank = artifacts.require("./Bank.sol");

module.exports = function(deployer) {
  deployer.deploy(Bank, "MIKE", 5);
};
