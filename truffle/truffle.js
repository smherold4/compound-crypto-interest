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
      from: "0x41431def7d9e2e28a6f3257d27a860e05dff8c00", // use the account-id generated during the setup process
      gas: 1000130620
    }
  }
};