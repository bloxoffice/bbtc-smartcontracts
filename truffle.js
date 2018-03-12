module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!

  networks : {
    rinkeby: {
      host: "localhost", // Connect to geth on the specified
      port: 8545,
      from: "0x13d7df226cf1119d4d81b7bc062c3d356a19b888", // default address to use for any transaction Truffle makes during migrations
      network_id: 4,
      gasprice : 1000000,
      gas: 6748126
    },
    development: {
      host: "localhost", // Connect to geth on the specified
      port: 8545,
      network_id: "*",
      gasprice : 1000000,
      gas: 6748126
    }
}
};
