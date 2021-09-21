const MetaverseMarket = artifacts.require("MetaverseMarket");
const TransparentUpgradeableProxy = artifacts.require('TransparentUpgradeableProxy');
const TheRocksCore = artifacts.require("TheRocksCore");
const ProxyAdmin = artifacts.require('ProxyAdmin');

module.exports = async function (deployer, network, accounts) {
    // New market
    deployer.deploy(MetaverseMarket, { from: accounts[0], overwrite: true })
        .then(async (instance) => {
            let market = await MetaverseMarket.at(TransparentUpgradeableProxy.address);
            const logic = instance.address;
            const proxyAdmin = await ProxyAdmin.at(ProxyAdmin.address);
            let tx = await proxyAdmin.upgrade(TransparentUpgradeableProxy.address, logic, { from: accounts[0] });
            console.log("Change implementation at tx: " + tx.tx);
            let impl = await proxyAdmin.getProxyImplementation(TransparentUpgradeableProxy.address);
            console.log("New Impl: " + impl);
            let trade = await market.getOrder(0);
            console.log("get order: " + trade.toString());
        });
};

// truffle run verify ProxyAdmin --network bscTestnet
// truffle run verify TransparentUpgradeableProxy --network bscTestnet

// 0xC4A66D5Dd5C6F9291e1C4C5b9131191a94fD37b1