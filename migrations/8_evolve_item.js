const TheRocksEvolver = artifacts.require('TheRocksEvolver');
const TheRocksCore = artifacts.require('TheRocksCore');

module.exports = async function (deployer, network, accounts) {
    let evolver = await TheRocksEvolver.at(TheRocksEvolver.address);
    let core = await TheRocksCore.at(TheRocksCore.address);
    // let characters = await core.getRock('1');
    // let trails = await evolver.decode(characters[0]);
    // console.log("Characters: " + characters);
    // console.log("exp: " + characters[1]);
    // console.log("level: " + characters[3]);
    // console.log("TRAILS: " + trails);

    let tx = await evolver.evolveItem(1, '1000');
    console.log("Evolve rock at tx: " + tx.tx);

    // characters = await core.getRock('1');
    // trails = await evolver.decode(characters[0]);
    // console.log("Characters: " + characters[0]);
    // console.log("exp: " + characters[1]);
    // console.log("level: " + characters[3]);
    // console.log("TRAILS: " + trails);
};