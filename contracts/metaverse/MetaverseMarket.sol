// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;

import "./MetaverseBaseMarket.sol";
import "../market/metadata/MarketEnumerable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract MetaverseMarket is NativeClassifieds(address(0)), MarketEnumerable, OwnableUpgradeable {
    using SafeMath for uint256;
    uint256 public tradingFee;
    mapping(address => bool) public approvedNfts;

    event OpenOrder(address indexed poster, uint256 itemId, uint256 orderId, uint256 price);
    event ExecuteOrder(address indexed seller, address indexed buyer, uint256 orderId, uint256 price);
    event CancelOrder(address indexed poster, uint256 orderId);
    event ApproveNFT(address nft, bool enable);

    constructor() {
        tradingFee = 5;
    }

    function initialize() public initializer {
        OwnableUpgradeable.__Ownable_init();
    }

    function setNFT(address _nftAddress, bool enable) public onlyOwner {
        approvedNfts[_nftAddress] = enable;
    }

    function setTradingFee(uint256 _tradingFee) public onlyOwner {
        require(_tradingFee < 20, "Set trading Fee to much!");
        tradingFee = _tradingFee;
    }

    // function _beforeOpen(uint256 _item, address _nftAddress, uint256 _price, uint256 _expireAt) internal virtual {}

    /**
     * @dev Opens a new order. Puts _item in escrow.
     * @param _item The id for the item to order.
     * @param _price The amount of currency for which to order the item.
     */
    function openOrder(uint256 _item, address _nftAddress, uint256 _price, uint256 _expireAt)
        public
        override
    {
        NativeClassifieds.openOrder(_item, _price, _nftAddress, _expireAt);
        MarketEnumerable._mint(msg.sender, orderCounter - 1);
        emit OpenOrder(msg.sender, _item, orderCounter - 1, _price);
    }

    function _beforeExecute(Order memory order) internal override {
        require(msg.value >= order.price, "Invalid price!");
        uint256 tFee = order.price.mul(tradingFee).div(100);
        payable(owner()).transfer(tFee);
        order.price = order.price - tFee;
    }

    /**
     * @dev Executes a order. Must have approved this contract to transfer the
     * amount of currency specified to the poster. Transfers ownership of the
     * item to the filler.
     * @param _order The id of an existing order
     */
    function executeOrder(uint256 _order)
        public
        payable
        override
    {
        NativeClassifieds.executeOrder(_order);
        _burn(_order);
        emit ExecuteOrder(orders[_order].poster, msg.sender, _order, orders[_order].price);
    }

    /**
     * @dev Cancels a order by the poster.
     * @param _order The order to be cancelled.
     */
    function cancelOrder(uint256 _order)
        public
        override
    {
        NativeClassifieds.cancelOrder(_order);
        MarketEnumerable._burn(_order);
        emit CancelOrder(msg.sender, _order);
    }

    /**
     * @dev this function is used for listing pagination orderIds item on trading market
     * @param begin the start position
     * @param end the end position (end will be excluded)
     */
    function openOrderByRange(uint256 begin, uint256 end)
        public
        view
        virtual
        returns (Order[] memory results)
    {
        uint256[] memory orderIds = openOrderIdsByRange(begin, end);
        return getOrders(orderIds);
    }

    /**
     * @dev this function is used for listing pagination orderIds item on trading market
     * @param begin the start position
     * @param end the end position (end will be excluded)
     */
    function openOrderOfOwnerByRange(address owner, uint256 begin, uint256 end)
        public
        view
        virtual
        returns (Order[] memory results)
    {
        uint256[] memory orderIds = openOrderIdsOfOwnerByRange(owner, begin, end);
        return getOrders(orderIds);
    }

    function getOrders(uint256[] memory orderIds)
        public
        view
        virtual
        returns (Order[] memory results)
    {
        results = new Order[](orderIds.length);
        for (uint256 i = 0; i < orderIds.length; i++) {
            results[i] = orders[orderIds[i]];
        }
        return results;
    }
}

