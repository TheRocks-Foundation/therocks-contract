const TheRocksCreator = artifacts.require('TheRocksCreator');
const TheRocksCore = artifacts.require("TheRocksCore");
const MyToken = artifacts.require("MyToken");

module.exports = async function (deployer, network, accounts) {
    let creator = await TheRocksCreator.at(TheRocksCreator.address);
    let core = await TheRocksCore.at(TheRocksCore.address);
    let token = await MyToken.at(MyToken.address);

    // owner create new rock
    //00001001000011101001
    let createRockOwner = await creator.createMultiItem(20, 37098, {from: accounts[0], gas: 10000000});
    console.log("Created 20 rocks at txn: " + createRockOwner.tx);



    // mint token from outside 
    // 00001001000011101001
    let approve = await token.approve(TheRocksCreator.address, '1000000000000000000000000', {from: accounts[1]});
    console.log("approve token at txn: " + approve.tx);
    let mintRock = await creator.mint(37097, {from: accounts[1], gas: 10000000});
    console.log("mint rock at txn: " + mintRock.tx);

};
