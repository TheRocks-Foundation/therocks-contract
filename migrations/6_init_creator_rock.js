const TheRocksCreator = artifacts.require('TheRocksCreator');
const TheRocksCore = artifacts.require("TheRocksCore");
const MyToken = artifacts.require("MyToken");
const lodash = require("lodash");

module.exports = async function (deployer, network, accounts) {
    let creator = await TheRocksCreator.at(TheRocksCreator.address);
    let core = await TheRocksCore.at(TheRocksCore.address);
    let token = await MyToken.at(MyToken.address);

    // owner create new rock
    //00001001000011101001
    {

        for (let i = 0; i < 50; i++) {
            let random = lodash.random(0, 1000000000);
            let char = encode(decode(random, 0), 0);
            console.log("Random char: " + char);
            let createRockOwner = await creator.createItem(char, { from: accounts[0], gas: 10000000 });
            console.log("Created rocks at txn: " + createRockOwner.tx);   
        }
    }


    {
        let random = lodash.random(0, 1000000000);
        // mint token from outside 
        // 00001001000011101001
        let char = encode(decode(random, 0), 0);
        console.log("New character: " + char);
        let approve = await token.approve(TheRocksCreator.address, '1000000000000000000000000', { from: accounts[1] });
        console.log("approve token at txn: " + approve.tx);
        let mintRock = await creator.mint(char, { from: accounts[1], gas: 10000000 });
        console.log("mint rock at txn: " + mintRock.tx);
    }

};

function _sliceNumber(_n, _nbits, _offset) {
    // mask is made by shifting left an offset number of times
    let mask = (2 ** _nbits - 1) << _offset;
    // AND n with mask, and trim to max of _nbits bits
    return (_n & mask) >> _offset;
}

function _get5Bits(_input, _slot) {
    return _sliceNumber(_input, 5, _slot * 5);
}

function decode(_characters, level) {
    let totalparts = level + 4;
    let traits = Array(totalparts);
    let i;
    for (i = 0; i < totalparts; i++) {
        traits[i] = _get5Bits(_characters, i) % 16;
    }
    return traits;
}

function encode(_traits, level) {
    let totalparts = level + 4;
    let _characters = 0;
    for (let i = 0; i < totalparts; i++) {
        _characters = _characters << 5;
        // bitwise OR trait with _characters
        _characters = _characters | _traits[(totalparts - 1) - i];
    }
    return _characters;
}
