const Web3 = require('web3');
var fs = require('fs');
const KEYSTORE_PASSWORD = 'mountdewmountdew';

const web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:8543"));

fs.readFile('/Users/herold/Downloads/0xE34C272d396c052781cBeccBC8dd497B990220BE.keystore', 
  function read(err, data) {
    if (err) {
        throw err;
    }
    var keystore = JSON.parse(data);
    keystore.crypto = keystore.Crypto;
    const decryptedAccount = web3.eth.accounts.decrypt(keystore, KEYSTORE_PASSWORD);
    sendTxn(decryptedAccount, "0x47f35b849b5d42361abb75c684f1fc2a369a6c9d");
});

function sendTxn(decryptedAccount, toAddress) {
  console.log("sending from  " + decryptedAccount.address)
  var rawTransaction = {
    "from": decryptedAccount.address,
    "to": toAddress,
    "value": web3.utils.toHex(web3.utils.toWei("0.08", "ether")),
    "gas": 200000,
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

// keystore = {
//   "version":3,
//   "id":"5b607b98-054e-4300-9ebf-6358ba0e33c9",
//   "address":"e34c272d396c052781cbeccbc8dd497b990220be",
//   "crypto":{
//     "ciphertext":"5534ce3c7fccb3a5d4cd07bc33d9dfb460bab84c46a6805a8148bb66152cb4e3",
//     "cipherparams":{
//       "iv":"d7eb4c5e5db04c90c9a8d4453d234862"
//     },
//     "cipher":"aes-128-ctr","kdf":"scrypt",
//     "kdfparams":{
//       "dklen":32,
//       "salt":"6344b1c33935b2af95a261c938f78a8eb134db930393ceda2a7d111fa66f25f9",
//       "n":8192,
//       "r":8,
//       "p":1
//     },
//     "mac":"e24078e00df1dad18a5484873e3cf0bcecd149554acf7dc8cc2be9dd6b7298b6"
//   }
// };
