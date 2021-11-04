const TheRocksUpdater = artifacts.require('TheRocksUpdater');
const TheRocksCore = artifacts.require("TheRocksCore");
const MyToken = artifacts.require("MyToken");

module.exports = function (deployer, network, accounts) {
    let nft = TheRocksCore.address;
    let token = '0xd301fc0f091d87f59db47e0c7255c967c55cdd96';
    deployer.deploy(TheRocksUpdater, nft, token, { from: accounts[0], overwrite: true }).then(async (instance) => {
        // let core = await TheRocksCore.at(TheRocksCore.address);
        // let tx = await core.setExpScientist(instance.address, true);
        // console.log("Exp Scientist has been whitelisted at tx: " + tx.tx);

        let setadmin = await instance.setAdmin("0xBBFd1Ef6cD4024494618819F6Cb7da4b37c2E09e", true);
        console.log("set admin at txn: " + setadmin.tx);
    });
    
    
};