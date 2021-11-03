// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/ITheRocksCore.sol";

contract TheRocksUpdater is Ownable {
    event UpdateItem(uint256 _rockId, uint8 _newLevel, uint256 _newExp);
    mapping(address => bool) public admins;
    ITheRocksCore theRocksCore;
    IERC20 theRocksToken;
    mapping(address => uint256) rewards;


    modifier onlyAdmin() {
        require(admins[msg.sender], "only allowed admin!");
        _;
    }

    constructor(address core, address token) {
        theRocksCore = ITheRocksCore(core);
        theRocksToken = IERC20(token);
        admins[msg.sender] = true;
    }

    function setAdmin(address _admin, bool _enable) public onlyOwner {
        admins[_admin] = _enable;
    }

    function calculateLevel(uint256 _newExp, uint8 currentLevel) public pure returns(uint8) {
        for (uint256 i = currentLevel; i <= 256; i++) {
            uint256 v = 1000*i*i + 4000*i;
            if(_newExp < v) {
                return uint8(i-1);
            }
        }
        // maximum level
        return 255;
    }    

    function calculateExp(uint256 level) public pure returns(uint256) {
        return 1000*level*level + 4000*level;
    }

    function _evolveItem(uint256 _rockId, uint256 _newExp) internal {
        (uint256 characters,,,uint8 level) = theRocksCore.getRock(_rockId);
        uint8 nextLevel = calculateLevel(_newExp, level);
        if(nextLevel > level) {
            _reward(_rockId, nextLevel);
        }
        theRocksCore.evolveRock(_rockId, characters, _newExp, nextLevel);
        emit UpdateItem(_rockId, nextLevel, _newExp);
    }

    function _reward(uint256 _rockId, uint8 _newLevel) internal {
        address rockOwner = theRocksCore.ownerOf(_rockId);
        rewards[rockOwner] += _newLevel * 5e9; 
    }

    function evolveItem(uint256 _rockId, uint256 _newExp) public onlyAdmin {
        _evolveItem(_rockId, _newExp);
    }

    function withdraw(uint256 amount) public onlyOwner {
        require(amount < address(this).balance, "WRONG AMOUNT!");
        payable(msg.sender).transfer(amount);
    }
}
