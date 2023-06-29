const TransparentUpgradeableProxy = artifacts.require('TransparentUpgradeableProxy');
const TheRocksUpdater = artifacts.require('TheRocksUpdater');
const TheRocksCore = artifacts.require('TheRocksCore');
const MyToken = artifacts.require("MyToken");
const ProxyAdmin = artifacts.require('ProxyAdmin');

module.exports = async function (deployer, network, accounts) {
    let nft = TheRocksCore.address;
    let token = MyToken.address;

    const logic = TheRocksUpdater.address;
    const proxyAdmin = ProxyAdmin.address;
    const data = '0x';
    deployer.deploy(TransparentUpgradeableProxy, logic, proxyAdmin, data, { from: accounts[0], overwrite: true })
        .then(async (instance) => {
            let updater = await TheRocksUpdater.at(instance.address);
            await updater.initialize(nft, token);
            console.log(await updater.owner());

            let core = await TheRocksCore.at(TheRocksCore.address);
            let tx = await core.setExpScientist(updater.address, true);
            console.log("Exp Scientist has been whitelisted at tx: " + tx.tx);

            let setadmin = await updater.setAdmin("0xBBFd1Ef6cD4024494618819F6Cb7da4b37c2E09e", true);
            console.log("set admin at txn: " + setadmin.tx);

            let setmul = await updater.setMultiplier(5000000000);
            console.log("set multiplier tx: " + setmul.tx);
        });
};