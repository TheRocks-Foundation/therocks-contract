// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;
import "@openzeppelin/contracts/access/Ownable.sol";

interface IDefishSpawningManager {
	function isSpawningAllowed(uint256 _genes, address _owner) external returns (bool);
  function isRebirthAllowed(uint256 _fishId, uint256 _genes) external returns (bool);
}

interface IDefishRetirementManager {
  function isRetirementAllowed(uint256 _fishId, bool _rip) external returns (bool);
}

interface IDefishMarketplaceManager {
  function isTransferAllowed(address _from, address _to, uint256 _fishId) external returns (bool);
}

interface IDefishStatManager {
  function isEvolvementAllowed(uint256 _fishId, uint256 _newStrength) external returns (bool);
}

// solium-disable-next-line lbrace
contract DefishManager is
  IDefishSpawningManager,
  IDefishRetirementManager,
  IDefishMarketplaceManager,
  IDefishStatManager,
  Ownable
{

  bool public allowedAll = true;

  function setAllowAll(bool _allowedAll) external onlyOwner {
    allowedAll = _allowedAll;
  }

  function isSpawningAllowed(uint256 _genes, address owner) external view override returns (bool) {
    require(owner != address(0), "Can not spawn fish to ZERO!");
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