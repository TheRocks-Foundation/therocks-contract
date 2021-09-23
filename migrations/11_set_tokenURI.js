const TheRocksCreator = artifacts.require('TheRocksCreator');
const TheRocksCore = artifacts.require("TheRocksCore");
const MyToken = artifacts.require("MyToken");
const lodash = require("lodash");

module.exports = async function (deployer, network, accounts) {
    let creator = await TheRocksCreator.at(TheRocksCreator.address);
    let core = await TheRocksCore.at(TheRocksCore.address);
    let tx = await core.setTokenURI("https://assets-testing.therocks.io/rock/", ".png")
    console.log("Set token uri at tx: " + tx.tx);
    

};
