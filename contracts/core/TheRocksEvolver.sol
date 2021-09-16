// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;

import './ExternalInterfaces/GeneScienceInterface.sol';
import './TheRocksCore.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TheRocksEvolver is Ownable {
    event EvolveItem(address owner, uint256 _rockId);
    mapping(address => bool) admins;
    IERC20 public feeToken;
    TheRocksCore theRocksCore;
    uint8 normalRange = 16;

    modifier onlyAdmin() {
        require(admins[msg.sender], "only allowed admin!");
        _;
    }

    constructor(address core) {
        theRocksCore = TheRocksCore(core);
        admins[msg.sender] = true;
    }

    function setAdmin(address _admin, bool _enable) public onlyOwner {
        admins[_admin] = _enable;
    }

    function _sliceNumber(uint256 _n, uint256 _nbits, uint256 _offset) private pure returns (uint256) {
        // mask is made by shifting left an offset number of times
        uint256 mask = uint256((2**_nbits) - 1) << _offset;
        // AND n with mask, and trim to max of _nbits bits
        return uint256((_n & mask) >> _offset);
    }

    function _get5Bits(uint256 _input, uint256 _slot) internal pure returns(uint8) {
        return uint8(_sliceNumber(_input, uint256(5), _slot * 5));
    }

    function _evolveItem(uint256 _rockId, uint256 _newExp)
        private
    {
        (uint256 characters,,,uint8 level) = theRocksCore.getRock(_rockId);
        // random new evolution character
        uint256 rand = uint256(keccak256(abi.encodePacked(_rockId, _newExp, blockhash(block.number-1), block.timestamp)));
        uint8 newCharacter = uint8(_sliceNumber(rand, 5, 0) % 16);
        uint256 evolveCharacters = (characters << 5) | newCharacter;
        theRocksCore.evolveRock(_rockId, evolveCharacters, _newExp, level+1);
        emit EvolveItem(msg.sender, _rockId);
    }

    function evolveItem(uint256 _rockId, uint256 _newExp)
        public
        onlyAdmin
    {
        _evolveItem(_rockId, _newExp);
    }

    function withdraw(uint256 amount) public onlyOwner {
        require(amount < address(this).balance, "WRONG AMOUNT!");
        payable(msg.sender).transfer(amount);
    }
}
