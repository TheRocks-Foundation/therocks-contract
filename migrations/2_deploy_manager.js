const DefishManager = artifacts.require("DefishManager");

module.exports = function (deployer, network, accounts) {
    deployer.deploy(DefishManager, { from: accounts[0], overwrite: true });
};