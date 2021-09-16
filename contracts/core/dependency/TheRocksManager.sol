// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./TheRocksDependency.sol";

// solium-disable-next-line lbrace
contract TheRocksManager is
  ITheRocksSpawningManager,
  ITheRocksRetirementManager,
  ITheRocksMarketplaceManager,
  ITheRocksExpManager,
  Ownable
{

  bool public allowedAll = true;

  function setAllowAll(bool _allowedAll) external onlyOwner {
    allowedAll = _allowedAll;
  }

  function isSpawningAllowed(uint256 _genes, address owner) external view override returns (bool) {
    require(owner != address(0), "Can not spawn rock to ZERO!");
    require(_genes != 0, "Invalid Genes!");
    return allowedAll;
  }

  function isRebirthAllowed(uint256, uint256 _genes) external view override returns (bool) {
    require(_genes != 0, "Invalid Genes!");
    return allowedAll;
  }

  function isRetirementAllowed(uint256, bool) external view override returns (bool) {
    return allowedAll;
  }

  function isTransferAllowed(address, address, uint256) external view override returns (bool) {
    return allowedAll;
  }

  function isEvolvementAllowed(uint256, uint256) external view override returns (bool) {
    return allowedAll;
  }
}