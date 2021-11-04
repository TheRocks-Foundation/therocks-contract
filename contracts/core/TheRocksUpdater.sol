// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/ITheRocksCore.sol";
import "./interface/ITheRocksReward.sol";

contract TheRocksUpdater is ITheRocksReward, Ownable{
    event UpdateItem(uint256 indexed _rockId, uint8 _newLevel, uint256 _newExp);
    event Reward(address indexed user, uint256 amount);
    event MultiplierChange(uint256 _newMul);
    mapping(address => bool) public admins;
    ITheRocksCore theRocksCore;
    IERC20 theRocksToken;
    mapping(address => uint256) rewards;
    uint256 public mul;


    modifier onlyAdmin() {
        require(admins[msg.sender], "only allowed admin!");
        _;
    }

    function reward(address user) external view override returns(uint256) {
        return rewards[user];
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
            _doReward(_rockId, nextLevel);
        }
        theRocksCore.evolveRock(_rockId, characters, _newExp, nextLevel);
        emit UpdateItem(_rockId, nextLevel, _newExp);
    }

    function _doReward(uint256 _rockId, uint8 _newLevel) internal {
        address rockOwner = theRocksCore.ownerOf(_rockId);
        rewards[rockOwner] += _newLevel * mul; 
    }

    function evolveItem(uint256 _rockId, uint256 _newExp) public override onlyAdmin {
        _evolveItem(_rockId, _newExp);
    }

    function claim() public override {
        uint256 _reward = rewards[msg.sender];
        require(_reward > 0, "Nothing to claim!");
        require(theRocksToken.balanceOf(address(this)) >= _reward, "We are out of service. Please claim later!");
        rewards[msg.sender] = 0;
        theRocksToken.transfer(msg.sender, _reward);
        emit Reward(msg.sender, _reward);
    }

    function setMultiplier(uint256 _mul) public onlyOwner {
        mul = _mul;
        emit MultiplierChange(mul);
    }

    function withdrawToken(address token, address to, uint value) external onlyOwner {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TRANSFER_FAILED');
    }

    function withdraw(uint256 amount) external onlyOwner {
        require(amount < address(this).balance, "WRONG AMOUNT!");
        payable(msg.sender).transfer(amount);
    }
}
