const TheRocksUpdater = artifacts.require('TheRocksUpdater');
const TheRocksCore = artifacts.require("TheRocksCore");
const MyToken = artifacts.require("MyToken");

module.exports = function (deployer, network, accounts) {
    nft = TheRocksCore.address;
    
    deployer.deploy(TheRocksUpdater, nft, { from: accounts[0], overwrite: true }).then(async (instance) => {
        let core = await TheRocksCore.at(TheRocksCore.address);
        let tx = await core.setExpScientist(instance.address, true);
        console.log("Exp Scientist has been whitelisted at tx: " + tx.tx);

        let setadmin = await instance.setAdmin("0xBBFd1Ef6cD4024494618819F6Cb7da4b37c2E09e", true);
        console.log("set admin at txn: " + setadmin.tx);
    });
    
    
};