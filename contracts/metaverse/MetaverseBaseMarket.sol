// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title MetaverseBaseMarket
 * @notice Implements the classifieds board market. The market will be governed
 * by an Native token as currency, and an ERC721 token that represents the
 * ownership of the items being orderd. Only ads for selling items are
 * implemented. The item tokenization is responsibility of the ERC721 contract
 * which should encode any item details.
 */
contract MetaverseBaseMarket {
    using SafeMath for uint256;
    
    event OrderStatusChange(uint256 ad, bytes32 status);

    struct Order {
        uint256 id;
        address seller;
        uint256 item;
        address nftAddress;
        uint256 price;
        uint256 expireAt;
        bytes32 status; // Open, Executed, Cancelled
    }

    mapping(uint256 => Order) public orders;
    // From ERC721 registry assetId to Order (to avoid asset collision)
    mapping (address => mapping(uint256 => Order)) public orderByAssetId;

    uint256 orderCounter = 0;
    
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

    // function _beforeOpen(uint256 _item, address _nftAddress, uint256 _price, uint256 _expireAt) internal virtual {}

    /**
     * @dev Opens a new order. Puts _item in escrow.
     * @param _item The id for the item to order.
     * @param _price The amount of currency for which to order the item.
     */
    function openOrder(uint256 _item, address _nftAddress, uint256 _price, uint256 _expireAt)
        public
        virtual
    {
        require(approvedNfts[_nftAddress], "NFT is not allowed trading on market!");
        require(msg.sender == _nftAddress.ownerOf(_item), "Only owner can open order!");
        require(_nftAddress.getApproved(_item) == address(this) || _nftAddress.isApprovedForAll(msg.sender, address(this)), "Marketplace need authorize from owner!");
        require(_price > 0, "Price must be greater than 0!");
        require(expiresAt > block.timestamp.add(1 minutes), "New Order lifecycle must longer than 1 minute!");
        // _beforeOpen(order);
        orders[orderCounter] = Order({
            id: orderCounter,
            seller: msg.sender,
            item: _item,
            nftAddress: _nftAddress,
            price: _price,
            expireAt: _expireAt,
            status: "Open"
        });
        orderCounter += 1;
        emit OrderStatusChange(orderCounter - 1, "Open");
    }

    function _beforeExecute(Order memory order) internal virtual {}

    /**
     * @dev Executes a order. Must have approved this contract to transfer the
     * amount of currency specified to the seller. Transfers ownership of the
     * item to the filler.
     * @param _order The id of an existing order
     */
    function executeOrder(uint256 _order)
        public
        payable
        virtual
    {
        Order memory order = orders[_order];
        require(order.status == "Open", "Order is not Open.");
        _beforeExecute(order);
        payable(order.seller).transfer(order.price);
        order.nftAddress.transferFrom(order.seller, msg.sender, order.item);
        orders[_order].status = "Executed";
        emit OrderStatusChange(_order, "Executed");
    }

    /**
     * @dev Cancels a order by the seller.
     * @param _order The order to be cancelled.
     */
    function cancelOrder(uint256 _order)
        public
        virtual
    {
        Order memory order = orders[_order];
        require(
            msg.sender == order.seller,
            "Order can be cancelled only by seller."
        );
        require(order.status == "Open", "Order is not Open.");
        orders[_order].status = "Cancelled";
        emit OrderStatusChange(_order, "Cancelled");
    }
}