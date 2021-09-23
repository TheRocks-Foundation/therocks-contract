const TheRocksCore = artifacts.require("TheRocksCore");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(TheRocksCore, { from: accounts[0], overwrite: false }).then(async (instance) => {
  });

};