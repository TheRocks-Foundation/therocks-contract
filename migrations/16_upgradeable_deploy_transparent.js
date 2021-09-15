const TransparentUpgradeableProxy = artifacts.require('TransparentUpgradeableProxy');
const NativeMarketClassifieds = artifacts.require("NativeMarketClassifieds");
const ProxyAdmin = artifacts.require('ProxyAdmin');
const MyToken = artifacts.require('MyToken');
const DefishCore = artifacts.require('DefishCore');

module.exports = function (deployer, network, accounts) {
    const logic = NativeMarketClassifieds.address;
    const proxyAdmin = ProxyAdmin.address;
    const data = '0x';
    deployer.deploy(TransparentUpgradeableProxy, logic, proxyAdmin, data, { from: accounts[0], overwrite: true })
        .then(async (instance) => {
            let market = await NativeMarketClassifieds.at(instance.address);
            await market.initialize();
            console.log(market.owner());
            await market.setTradingFee(5, { from: accounts[0] });
            // await market.setERC20(MyToken.address, { from: accounts[0] });
            await market.setNFT(DefishCore.address, { from: accounts[0] });
        });
};

// truffle run verify ProxyAdmin --network bscTestnet
// truffle run verify TransparentUpgradeableProxy --network bscTestnet