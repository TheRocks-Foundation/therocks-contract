const ERC20MarketClassifieds = artifacts.require("ERC20MarketClassifieds");
const TheRocksCore = artifacts.require("TheRocksCore");

module.exports = async function (deployer, network, accounts) {
    let market = await ERC20MarketClassifieds.at(ERC20MarketClassifieds.address);
    let core = await TheRocksCore.at(TheRocksCore.address);

    let ownerNft = await core.balanceOf(accounts[0]);
    console.log("Current fishes of accounts[0]: " + ownerNft);
    let tokenIds = [];
    for (let index = 0; index < ownerNft/2; index++) {
        let tokenId = await core.tokenOfOwnerByIndex(accounts[0], index);
        tokenIds[index] = tokenId;
    }

    for (let index = 0; index < ownerNft/2; index++) {
        let txn = await market.openTrade(tokenIds[index], '100000000000', { from: accounts[0] })
        console.log("Open trade fishId " + tokenIds[index] + " at txn:" + txn.tx);
    }
};