const TheRocksEvolver = artifacts.require('TheRocksEvolver');
const TheRocksCore = artifacts.require("TheRocksCore");
const MyToken = artifacts.require("MyToken");

module.exports = function (deployer, network, accounts) {
    nft = TheRocksCore.address;
    
    deployer.deploy(TheRocksEvolver, nft, { from: accounts[0], overwrite: true }).then(async (instance) => {
        let core = await TheRocksCore.at(TheRocksCore.address);
        let tx = await core.setExpScientist(instance.address, true);
        console.log("Exp Scientist has been whitelisted at tx: " + tx.tx);
    });
    
    
};