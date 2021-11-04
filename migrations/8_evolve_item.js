const TheRocksUpdater = artifacts.require('TheRocksUpdater');
const TheRocksCore = artifacts.require('TheRocksCore');

module.exports = async function (deployer, network, accounts) {
    let updater = await TheRocksUpdater.at(TheRocksUpdater.address);
    let core = await TheRocksCore.at(TheRocksCore.address);

    // let evolvetx = await updater.evolveItem(99, 5000);
    // console.log("evolve tx: " + evolvetx.tx);
    // let reward = await updater.rewards('0x7c3487cec3635ab75c6f7b30e002ef9fc20685e4');
    // console.log(reward);

    // let claim = await updater.claim();
    // console.log("claim: "+ claim.tx);

    let withdraw = await updater.withdrawToken('0xf9cc6b0c2c01cdd44bc4d3f603cf6e774e54f92d', '0x7c3487cec3635ab75c6f7b30e002ef9fc20685e4', '100000000000');
    console.log(withdraw.tx);
};