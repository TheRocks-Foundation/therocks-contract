const NativeMarketClassifieds = artifacts.require("NativeMarketClassifieds");
const TheRocksCore = artifacts.require("TheRocksCore");
const Web3 = require('web3');

module.exports = async function (deployer, network, accounts) {
    var web3 = new Web3(deployer.provider);
    let market = await NativeMarketClassifieds.at(NativeMarketClassifieds.address);
    let core = await TheRocksCore.at(TheRocksCore.address);
    let startingBalance;
    await web3.eth.getBalance(accounts[1]).then(function (balance) {startingBalance = balance});
    console.log("Account[1] Starting Balance: " + startingBalance.toString() );

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
    let tx = await market.executeTrade(orderIds[0], {from: accounts[1], value: price});

    // // retrieve ending balance after trade
    let endingBalance
    await web3.eth.getBalance(accounts[1]).then(function (balance) {endingBalance = balance});
    console.log("Actually Ending Balance: " + endingBalance);

};