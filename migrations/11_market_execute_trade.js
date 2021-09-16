const MyToken = artifacts.require("MyToken");
const ERC20MarketClassifieds = artifacts.require("ERC20MarketClassifieds");
const TheRocksCore = artifacts.require("TheRocksCore");

module.exports = async function (deployer, network, accounts) {
    let market = await ERC20MarketClassifieds.at(ERC20MarketClassifieds.address);
    let core = await TheRocksCore.at(TheRocksCore.address);
    let token = await MyToken.at(MyToken.address);

    let startingBalance = await token.balanceOf(accounts[1]);
    console.log("Account[1] Starting Balance: " + startingBalance);

    // retrieve open order
    let totalOpenOrder = await market.totalOpenOrder();
    let orderIds = await market.openOrderIdsByRange(0, totalOpenOrder);
    console.log(orderIds.toString());

    // retrieve orderId[0]
    let item = await market.getTrade(orderIds[0]);
    let price = item[2];
    console.log("OrderId: " + orderIds[0] + "\nItemId: " + item[1].toString() + "\nItem Price: " + price.toString());

    console.log("Expecting Balance After Buy: " + (startingBalance - price));
    // // execute orderId[0]
    let tx = await market.executeTrade(orderIds[0], {from: accounts[1]});

    // // retrieve ending balance after trade
    let endingBalance = await token.balanceOf(accounts[1]);
    console.log("Actually Ending Balance: " + endingBalance);

};