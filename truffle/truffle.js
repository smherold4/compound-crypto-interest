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
from: "0x0df84041ada8e6efbd01b05a5e4902bdc4967407", // use the account-id generated during the setup process
gas: 20000000
}
}
};