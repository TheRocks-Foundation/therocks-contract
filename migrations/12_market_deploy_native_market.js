const NativeMarketClassifieds = artifacts.require("NativeMarketClassifieds");
const DefishCore = artifacts.require("DefishCore");
const MyToken = artifacts.require("MyToken");

module.exports = function (deployer, network, accounts) {
  let tokenAddress = MyToken.address;
  // if (deployer.network_id == 56) {
  //   tokenAddress = '0xffffffffffffffffffffffffffffffffffffffff';
  // }
  deployer.deploy(NativeMarketClassifieds, { from: accounts[0], overwrite: true })
    .then(async (instance) => {
      await instance.initialize();

      let setnft = await instance.setNFT(DefishCore.address, { from: accounts[0] });
      console.log("Market NFT Core has been set at txn: " + setnft.tx);

      // approve trade NFT on market
      let core = await DefishCore.at(DefishCore.address);
      let approveTxn = await core.setApprovalForAll(instance.address, true, { from: accounts[0] });
      console.log("Approve market trading for accounts[0] at txn: " + approveTxn.tx);
    });
};

// truffle run verify NativeMarketClassifieds --network bscTestnet