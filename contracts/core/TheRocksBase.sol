// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;


import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./dependency/TheRocksDependency.sol";
import "./TheRocksAccessControl.sol";

contract TheRocksBase is ERC721Enumerable, TheRocksDependency, TheRocksAccessControl {
  string public tokenURIPrefix = "https://assets.therocks.io/rock/";
  string public tokenURISuffix = ".png";

  constructor() ERC721("TheRocks NFT", "ROCK") {
      
  }

  function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
      return super.supportsInterface(interfaceId);
  }

  function _baseURI() internal view override returns (string memory) {
      return tokenURIPrefix;
  }

  function tokenURI(uint256 tokenId) public view override returns (string memory) {
    string memory uri = super.tokenURI(tokenId);
      return bytes(uri).length > 0 ? string(abi.encodePacked(uri, tokenURISuffix)) : "";
  }

  function setTokenURI(string memory _prefix, string memory _suffix) external onlyCEO {
    tokenURIPrefix = _prefix;
    tokenURISuffix = _suffix;
  }

  function _beforeTokenTransfer(address from, address to, uint256 tokenId) whenTransferAllowed(from, to, tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}