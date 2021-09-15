// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;

import "./classified/NativeClassifieds.sol";
import "./metadata/MarketEnumerable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract NativeMarketClassifieds is NativeClassifieds(address(0)), MarketEnumerable, OwnableUpgradeable {
    using SafeMath for uint256;
    uint256 public tradingFee;

    event OpenTrade(address indexed poster, uint256 itemId, uint256 tradeId, uint256 price);
    event ExecuteTrade(address indexed seller, address indexed buyer, uint256 tradeId, uint256 price);
    event CancelTrade(address indexed poster, uint256 tradeId);

    constructor() {
        tradingFee = 5;
    }

    function initialize() public initializer {
        OwnableUpgradeable.__Ownable_init();
    }

    function setNFT(address _itemTokenAddress) public onlyOwner {
        itemToken = IERC721(_itemTokenAddress);
    }

    /**
     * @dev Opens a new trade. Puts _item in escrow.
     * @param _item The id for the item to trade.
     * @param _price The amount of currency for which to trade the item.
     */
    function openTrade(uint256 _item, uint256 _price)
        public
        override
    {
        NativeClassifieds.openTrade(_item, _price);
        MarketEnumerable._mint(msg.sender, tradeCounter - 1);
        emit OpenTrade(msg.sender, _item, tradeCounter - 1, _price);
    }

    function _beforeExecute(Trade memory trade) internal override {
        require(msg.value >= trade.price, "Invalid price!");
        uint256 tFee = trade.price.mul(tradingFee).div(100);
        payable(owner()).transfer(tFee);
        trade.price = trade.price - tFee;
    }

    /**
     * @dev Executes a trade. Must have approved this contract to transfer the
     * amount of currency specified to the poster. Transfers ownership of the
     * item to the filler.
     * @param _trade The id of an existing trade
     */
    function executeTrade(uint256 _trade)
        public
        payable
        override
    {
        NativeClassifieds.executeTrade(_trade);
        _burn(_trade);
        emit ExecuteTrade(trades[_trade].poster, msg.sender, _trade, trades[_trade].price);
    }

    /**
     * @dev Cancels a trade by the poster.
     * @param _trade The trade to be cancelled.
     */
    function cancelTrade(uint256 _trade)
        public
        override
    {
        NativeClassifieds.cancelTrade(_trade);
        MarketEnumerable._burn(_trade);
        emit CancelTrade(msg.sender, _trade);
    }

    /**
     * @dev this function is used for listing pagination orderIds item on trading market
     * @param begin the start position
     * @param end the end position (end will be excluded)
     */
    function openTradeByRange(uint256 begin, uint256 end)
        public
        view
        virtual
        returns (Trade[] memory results)
    {
        uint256[] memory orderIds = openOrderIdsByRange(begin, end);
        return getTrades(orderIds);
    }

    /**
     * @dev this function is used for listing pagination orderIds item on trading market
     * @param begin the start position
     * @param end the end position (end will be excluded)
     */
    function openTradeOfOwnerByRange(address owner, uint256 begin, uint256 end)
        public
        view
        virtual
        returns (Trade[] memory results)
    {
        uint256[] memory orderIds = openOrderIdsOfOwnerByRange(owner, begin, end);
        return getTrades(orderIds);
    }

    function getTrades(uint256[] memory orderIds)
        public
        view
        virtual
        returns (Trade[] memory results)
    {
        results = new Trade[](orderIds.length);
        for (uint256 i = 0; i < orderIds.length; i++) {
            results[i] = trades[orderIds[i]];
        }
        return results;
    }


    function setTradingFee(uint256 _tradingFee) public onlyOwner {
        require(_tradingFee < 20, "Set trading Fee to much!");
        tradingFee = _tradingFee;
    }
}

