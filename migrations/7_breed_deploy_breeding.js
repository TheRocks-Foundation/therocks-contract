const TheRocksBreeding = artifacts.require('TheRocksBreeding');
const TheRocksCore = artifacts.require("TheRocksCore");
const GeneScienceV1 = artifacts.require('GeneScienceV1');


module.exports = function (deployer, network, accounts) {
    deployer.deploy(TheRocksBreeding, TheRocksCore.address, { from: accounts[0], overwrite: true }).then(async (instance) => {
        // set genes science
        let setgenetx = await instance.setGeneScienceAddress(GeneScienceV1.address);
        console.log("Breeding Contract set GeneScienceV1 at txn: " + setgenetx.tx);

        // whitelist spawning
        let core = await TheRocksCore.at(TheRocksCore.address);
        let tx = await core.setSpawner(instance.address, true);
        console.log("Breeding Contract has been whitelisted at tx: " + tx.tx);
    });
    
};