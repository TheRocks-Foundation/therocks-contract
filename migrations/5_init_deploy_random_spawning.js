const TheRocksRandomSpawning = artifacts.require('TheRocksRandomSpawning');
const TheRocksCore = artifacts.require("TheRocksCore");
const GeneScienceV1 = artifacts.require('GeneScienceV1');

module.exports = function (deployer, network, accounts) {
    deployer.deploy(TheRocksRandomSpawning, TheRocksCore.address, { from: accounts[0], overwrite: true }).then(async (instance) => {
        let core = await TheRocksCore.at(TheRocksCore.address);
        let tx = await core.setSpawner(instance.address, true);
        console.log("Spawner has been whitelisted at tx: " + tx.tx);

        // set genes science
        let setgenetx = await instance.setGeneScienceAddress(GeneScienceV1.address);
        console.log("Random Spawning Contract set GeneScienceV1 at txn: " + setgenetx.tx);
    });
    
    
};