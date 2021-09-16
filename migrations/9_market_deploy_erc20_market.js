const ERC20MarketClassifieds = artifacts.require("ERC20MarketClassifieds");
const TheRocksCore = artifacts.require("TheRocksCore");
const MyToken = artifacts.require("MyToken");

module.exports = function (deployer, network, accounts) {
  let tokenAddress = MyToken.address;
  if (deployer.network_id == 56) {
    tokenAddress = '0xffffffffffffffffffffffffffffffffffffffff';
  }
  deployer.deploy(ERC20MarketClassifieds, { from: accounts[0], overwrite: true })
    .then(async (instance) => {
      await instance.initialize();
      let seterc20 = await instance.setERC20(tokenAddress, { from: accounts[0] });
      console.log("Market trade token has been set at txn: " + seterc20.tx);

      let setnft = await instance.setNFT(TheRocksCore.address, { from: accounts[0] });
      console.log("Market NFT Core has been set at txn: " + setnft.tx);

      // approve trade NFT on market
      let core = await TheRocksCore.at(TheRocksCore.address);
      let approveTxn = await core.setApprovalForAll(instance.address, true, { from: accounts[0] });
      console.log("Approve market trading for accounts[0] at txn: " + approveTxn.tx);

      // approve market on transfer Token
      let token = await MyToken.at(MyToken.address);
      let approveTransfer = await token.approve(instance.address, '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff', { from: accounts[1] });
      console.log("Approve Token Transfer for accounts[0] at txn: " + approveTransfer.tx);
    });
};

// truffle run verify ERC20MarketClassifieds --network bscTestnet