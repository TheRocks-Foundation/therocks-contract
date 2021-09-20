const TheRocksCreator = artifacts.require('TheRocksCreator');
const TheRocksCore = artifacts.require("TheRocksCore");
const MyToken = artifacts.require("MyToken");

module.exports = async function (deployer, network, accounts) {
    token = MyToken.address;
    nft = TheRocksCore.address;
    
    deployer.deploy(TheRocksCreator, nft, token, { from: accounts[0], overwrite: true }).then(async (instance) => {
        let core = await TheRocksCore.at(TheRocksCore.address);
        let tx = await core.setSpawner(instance.address, true);
        console.log("Spawner has been whitelisted at tx: " + tx.tx);
    });
    
    // let core = await TheRocksCore.at(TheRocksCore.address);
    // let tx = await core.setTokenURI("https://assets.therocks.io/rock/", ".png", {from: accounts[0]});
    // console.log("set token uri at tx: " + tx.tx);
    // let token = await core.tokenURI(1);
    // console.log(token);
};