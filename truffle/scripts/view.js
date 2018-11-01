//this scripts assumes a connection to the coinbase account which has the funds to create the needed tx

const INVESTOR = '0xE34C272d396c052781cBeccBC8dd497B990220BE';
var Bank = artifacts.require("./Bank.sol");

module.exports = function(callback) {
  var current_timestamp = parseInt(new Date().getTime() / 1000);
  Bank.deployed().then(function(contract) {
    return contract.amountOwed.call(INVESTOR)
    return contract.getInvestment.call(INVESTOR)
  }).then(function(result) {
    console.log(result.toString());
  }).catch(function(err) {
    console.log(err);
  });
}