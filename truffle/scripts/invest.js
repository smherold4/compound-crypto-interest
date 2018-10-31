//this scripts assumes a connection to the coinbase account which has the funds to create the needed tx

const INVESTOR = '0xE34C272d396c052781cBeccBC8dd497B990220BE';
var Bank = artifacts.require("./Bank.sol");

module.exports = function(callback) {
  Bank.deployed().then(function(contract) {
    return contract.invest(INVESTOR, 2.3e18, 5)
  }).then(function(result) {
    console.log(result);
  }).catch(function(err) {
    console.log(err);
  });
}