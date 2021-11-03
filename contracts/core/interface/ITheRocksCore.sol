// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ITheRocksCore is IERC721 {
    function getRock(uint256 _rockId) external view returns (uint256 character, uint256 exp, uint256 bornAt,uint8 level);
    function spawnRock(uint256 _character,address _owner, uint256 _delay) external returns(uint256);
    function rebirthRock(uint256 _rockId,uint256 _character,uint256 delay) external ;
    function evolveRock(uint256 _rockId,uint256 _advanceCharacter,uint256 _newExp,uint8 _newLevel) external;
}