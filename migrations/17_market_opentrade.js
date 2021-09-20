const MetaverseMarket = artifacts.require("MetaverseMarket");
const TransparentUpgradeableProxy = artifacts.require('TransparentUpgradeableProxy');
const TheRocksCore = artifacts.require("TheRocksCore");
const lodash = require("lodash");
const bn = require("bn.js");

module.exports = async function (deployer, network, accounts) {
    let marketAddress = TransparentUpgradeableProxy.address;
    let market = await MetaverseMarket.at(marketAddress);
    let core = await TheRocksCore.at(TheRocksCore.address);
    let nft = TheRocksCore.address;

    // check allow nft trading
    let isAllow = await market.approvedNfts(nft);
    if(!isAllow) {
        let tx = await market.listing(nft, true, {from: accounts[0]});
        console.log("Listing TheRock to market at tx: " + tx.tx);
    }
    let isApproved = await core.isApprovedForAll(accounts[0], marketAddress);
    if(!isApproved) {
        let tx = await core.setApprovalForAll(marketAddress, true, {from: accounts[0]});
        console.log("Set approval for all to market at tx: " + tx.tx);
    }

    let ownerNft = await core.balanceOf(accounts[0]);
    console.log("Current rocks of accounts[0]: " + ownerNft);
    let tokenIds = [];
    for (let index = 0; index < ownerNft; index++) {
        let tokenId = await core.tokenOfOwnerByIndex(accounts[0], index);
        tokenIds[index] = tokenId;
    }

    for (let index = 40; index < ownerNft; index++) {
        let random = lodash.random(0, 100);
        let price = new bn('1000000000').muln(random);
        let txn = await market.openOrder(tokenIds[index], nft, price, 1641775738, { from: accounts[0] })
        console.log("Open trade rockId " + tokenIds[index] + " at txn: " + txn.tx);
    }
};