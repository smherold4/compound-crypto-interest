//this scripts assumes a connection to the coinbase account which has the funds to create the needed tx

const RATE = '11';
var Bank = artifacts.require("./Bank.sol");

module.exports = function(callback) {
  Bank.deployed().then(function(contract) {
    return contract.setInterestRate(9)
  }).then(function(result, result2) {
    console.log(result);
  }).catch(function(err) {
    console.log(err);
  });
}