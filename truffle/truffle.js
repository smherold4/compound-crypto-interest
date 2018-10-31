module.exports = {
rpc: {
host:"localhost",
port:8543
},
networks: {
development: {
host: "localhost", //our network is running on localhost
port: 8543, // port where your blockchain is running
network_id: "*",
from: "0x81b4f192bf9c209c2907dd98973bc1f9d67b5170", // use the account-id generated during the setup process
gas: 20000000
}
}
};