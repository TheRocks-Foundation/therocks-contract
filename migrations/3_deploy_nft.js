const TheRocksCore = artifacts.require("TheRocksCore");
const TheRocksManager = artifacts.require("TheRocksManager");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(TheRocksCore, { from: accounts[0], overwrite: true }).then(async (instance) => {
    let tx = await instance.setSpawningManager(TheRocksManager.address);
    console.log("Spawning Manager has been set at tx: " + tx.tx);
  });

};
// truffle run verify MyToken --network bscTestnet
// truffle run verify TheRocksManager --network bscTestnet
// truffle run verify TheRocksCore --network bscTestnet
// truffle run verify TheRocksRandomSpawning --network bscTestnet
// truffle run verify ERC20MarketClassifieds --network bscTestnet
// mainnet: 0x221CC495166982D54c09233a7DCF17Dc9b94c9E7