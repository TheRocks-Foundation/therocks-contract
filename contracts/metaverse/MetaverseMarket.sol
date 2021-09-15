// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;

import "./MetaverseBaseMarket.sol";
import "../metadata/MarketEnumerable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract MetaverseMarket is MetaverseBaseMarket, MarketEnumerable, OwnableUpgradeable {
    using SafeMath for uint256;
    uint256 public tradingFee;

    event OpenOrder(address indexed poster, address _nftAddress, uint256 itemId, uint256 orderId, uint256 price);
    event ExecuteOrder(address indexed seller, address indexed buyer, uint256 orderId, uint256 price);
    event CancelOrder(address indexed poster, uint256 orderId);
    event ApproveNFT(address nft, bool enable);

    constructor() {
        tradingFee = 5;
    }

    function initialize() public initializer {
        OwnableUpgradeable.__Ownable_init();
    }

    function setTradingFee(uint256 _tradingFee) public onlyOwner {
        require(_tradingFee < 20, "Set trading Fee to much!");
        tradingFee = _tradingFee;
    }

    function listing(address _nftAddress, bool enable) public onlyOwner virtual {
        approvedNfts[_nftAddress] = enable;
    }

    /**
     * @dev Returns the details for a order.
     * @param _order The id for the order.
     */
    function getOrder(uint256 _order)
        public
        virtual
        view
        returns(address, uint256, address, uint256, uint256, bytes32)
    {
        Order memory order = orders[_order];
        return (order.seller, order.item, order.nftAddress, order.price, order.expireAt, order.status);
    }

    function getOrderByAssetId(address nftAddress, uint256 assetId) public view returns(uint256 orderId) {
        orderId = orderByAssetId[nftAddress][assetId];
    }

    // function _beforeOpen(uint256 _item, address _nftAddress, uint256 _price, uint256 _expireAt) internal virtual {}

    /**
     * @dev Opens a new order.
     * @param _item The id for the item to order.
     * @param _nftAddress located of asset
     * @param _price The amount of currency for which to order the item.
     * @param _expireAt expire time for Order
     */
    function openOrder(uint256 _item, address _nftAddress, uint256 _price, uint256 _expireAt)
        public
        override
        returns(uint256 orderId)
    {
        orderId = MetaverseBaseMarket.openOrder(_item, _nftAddress, _price, _expireAt);
        MarketEnumerable._mint(msg.sender, orderId);
        emit OpenOrder(msg.sender, _nftAddress, _item, orderId, _price);
    }

    function _beforeExecute(Order memory order) internal override {
        super._beforeExecute(order);
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
        MetaverseBaseMarket.executeOrder(_order);
        _burn(_order);
        emit ExecuteOrder(orders[_order].seller, msg.sender, _order, orders[_order].price);
    }

    /**
     * @dev Cancels a order by the poster.
     * @param _order The order to be cancelled.
     */
    function cancelOrder(uint256 _order)
        public
        override
    {
        MetaverseBaseMarket.cancelOrder(_order);
        MarketEnumerable._burn(_order);
        emit CancelOrder(msg.sender, _order);
    }
}

