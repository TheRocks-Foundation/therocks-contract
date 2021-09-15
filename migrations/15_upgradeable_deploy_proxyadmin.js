const ProxyAdmin = artifacts.require('ProxyAdmin');

module.exports = function (deployer, network, accounts) {
    deployer.deploy(ProxyAdmin, { from: accounts[0], overwrite: true });
};

// truffle run verify ProxyAdmin --network bscTestnet
// truffle run verify Upgradeable --network bscTestnet