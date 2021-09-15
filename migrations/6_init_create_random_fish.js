const DefishRandomSpawning = artifacts.require('DefishRandomSpawning');
const DefishCore = artifacts.require("DefishCore");
const GeneScience = artifacts.require("GeneScienceV1");

module.exports = async function (deployer, network, accounts) {
    let spawner = await DefishRandomSpawning.at(DefishRandomSpawning.address);
    let createFishTxn = await spawner.createMultiFish(20, {from: accounts[0], gas: 10000000});
    console.log("Created 50 fishes at txn: " + createFishTxn.tx);
    // let tx = await spawner.setGeneScienceAddress(GeneScience.address);
    // console.log("change Gene Science at transaction: " + tx.tx);
};
