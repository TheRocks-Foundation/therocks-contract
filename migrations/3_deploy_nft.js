const DefishCore = artifacts.require("DefishCore");
const DefishManager = artifacts.require("DefishManager");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(DefishCore, { from: accounts[0], overwrite: true }).then(async (instance) => {
    let tx = await instance.setSpawningManager(DefishManager.address);
    console.log("Spawning Manager has been set at tx: " + tx.tx);
  });

};
// truffle run verify MyToken --network bscTestnet
// truffle run verify DefishManager --network bscTestnet
// truffle run verify DefishCore --network bscTestnet
// truffle run verify DefishRandomSpawning --network bscTestnet
// truffle run verify ERC20MarketClassifieds --network bscTestnet
// mainnet: 0x221CC495166982D54c09233a7DCF17Dc9b94c9E7