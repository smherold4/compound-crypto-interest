const Web3 = require('web3');
var fs = require('fs');
const KEYSTORE_PASSWORD = 'mountdewmountdew';
const CONTRACT_ADDR = '0x7a47579db6fc0990cddd4429b5b806c34efaee74';

const web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:8543"));

fs.readFile('/Users/herold/Downloads/0xE34C272d396c052781cBeccBC8dd497B990220BE.keystore',
  function read(err, data) {
    if (err) {
        throw err;
    }
    var keystore = JSON.parse(data);
    keystore.crypto = keystore.Crypto;
    const decryptedAccount = web3.eth.accounts.decrypt(keystore, KEYSTORE_PASSWORD);
    sendTxn(decryptedAccount, CONTRACT_ADDR);
});

function sendTxn(decryptedAccount, toAddress) {
  console.log("sending from  " + decryptedAccount.address)
  var rawTransaction = {
    "from": decryptedAccount.address,
    "to": toAddress,
    "value": web3.utils.toHex(web3.utils.toWei("3.30", "ether")),
    "gas": 2000000,
    "chainId": 143
  };

  decryptedAccount.signTransaction(rawTransaction)
  .then(signedTx => {
    console.log("sending... " + signedTx.rawTransaction);
    web3.eth.sendSignedTransaction(signedTx.rawTransaction)
    .then(receipt => console.log("Transaction receipt: ", receipt))
    .catch(err => console.error(err))
  })
}
