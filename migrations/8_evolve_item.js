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

    let tx  = evolver.evolveItem(1, '12312312');
    console.log("Evolve rock at tx: " + tx.tx);

    // characters = await core.getRock('1');
    // trails = await evolver.decode(characters[0]);
    // console.log("Characters: " + characters[0]);
    // console.log("exp: " + characters[1]);
    // console.log("level: " + characters[3]);
    // console.log("TRAILS: " + trails);
};

// function _sliceNumber( _n,  _nbits,  _offset) {
//     // mask is made by shifting left an offset number of times
//     let mask = ((2**_nbits) - 1) << _offset;
//     // AND n with mask, and trim to max of _nbits bits
//     return ((_n & mask) >> _offset);
// }

// function _get5Bits( _input,  _slot) {
//     return (_sliceNumber(_input, (5), _slot * 5));
// }

// function decode( _characters) {
//     let traits;
//      i;
//     for(i = 0; i < 4; i++) {
//         traits[i] = _get5Bits(_characters, i);
//     }
//     return traits;
// }

// function encode(_traits) {
//     _characters = 0;
//     for( i = 0; i < 4; i++) {
//         _characters = _characters << 5;
//         // bitwise OR trait with _characters
//         _characters = _characters | _traits[3 - i];
//     }
//     return _characters;
// }