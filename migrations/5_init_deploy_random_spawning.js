const DefishRandomSpawning = artifacts.require('DefishRandomSpawning');
const DefishCore = artifacts.require("DefishCore");
const GeneScienceV1 = artifacts.require('GeneScienceV1');

module.exports = function (deployer, network, accounts) {
    deployer.deploy(DefishRandomSpawning, DefishCore.address, { from: accounts[0], overwrite: true }).then(async (instance) => {
        let core = await DefishCore.at(DefishCore.address);
        let tx = await core.setSpawner(instance.address, true);
        console.log("Spawner has been whitelisted at tx: " + tx.tx);

        // set genes science
        let setgenetx = await instance.setGeneScienceAddress(GeneScienceV1.address);
        console.log("Random Spawning Contract set GeneScienceV1 at txn: " + setgenetx.tx);
    });
    
    
};