const TheRocksManager = artifacts.require("TheRocksManager");

module.exports = function (deployer, network, accounts) {
    deployer.deploy(TheRocksManager, { from: accounts[0], overwrite: true });
};