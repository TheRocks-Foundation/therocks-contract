const TheRocksRandomSpawning = artifacts.require('TheRocksRandomSpawning');
const TheRocksCore = artifacts.require("TheRocksCore");
const GeneScience = artifacts.require("GeneScienceV1");

module.exports = async function (deployer, network, accounts) {
    let spawner = await TheRocksRandomSpawning.at(TheRocksRandomSpawning.address);
    let createFishTxn = await spawner.createMultiFish(20, {from: accounts[0], gas: 10000000});
    console.log("Created 50 fishes at txn: " + createFishTxn.tx);
    // let tx = await spawner.setGeneScienceAddress(GeneScience.address);
    // console.log("change Gene Science at transaction: " + tx.tx);
};
