const TheRocksUpdater = artifacts.require('TheRocksUpdater');

module.exports = function (deployer, network, accounts) {
    deployer.deploy(TheRocksUpdater, { from: accounts[0], overwrite: true }).then(async (instance) => {
    });
};