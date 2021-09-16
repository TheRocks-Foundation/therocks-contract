// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;

interface ITheRocksSpawningManager {
	function isSpawningAllowed(uint256 _genes, address _owner) external returns (bool);
  function isRebirthAllowed(uint256 _rockId, uint256 _genes) external returns (bool);
}

interface ITheRocksRetirementManager {
  function isRetirementAllowed(uint256 _rockId, bool _rip) external returns (bool);
}

interface ITheRocksMarketplaceManager {
  function isTransferAllowed(address _from, address _to, uint256 _rockId) external returns (bool);
}

interface ITheRocksExpManager {
  function isEvolvementAllowed(uint256 _rockId, uint256 _newStrength) external returns (bool);
}

contract TheRocksDependency {
  address public whitelistSetterAddress;

  ITheRocksSpawningManager public spawningManager;
  ITheRocksRetirementManager public retirementManager;
  ITheRocksMarketplaceManager public marketplaceManager;
  ITheRocksExpManager public expManager;

  mapping (address => bool) public whitelistedSpawner;
  mapping (address => bool) public whitelistedByeSayer;
  mapping (address => bool) public whitelistedMarketplace;
  mapping (address => bool) public whitelistedExpScientist;

  constructor() {
    whitelistSetterAddress = msg.sender;
  }

  modifier onlyWhitelistSetter() {
    require(msg.sender == whitelistSetterAddress);
    _;
  }

  modifier whenSpawningAllowed(uint256 _genes, address _owner) {
    require(
      spawningManager == ITheRocksSpawningManager(address(0)) ||
        spawningManager.isSpawningAllowed(_genes, _owner)
    );
    _;
  }

  modifier whenRebirthAllowed(uint256 _rockId, uint256 _genes) {
    require(
      address(spawningManager) == address(0) ||
        spawningManager.isRebirthAllowed(_rockId, _genes)
    );
    _;
  }

  modifier whenRetirementAllowed(uint256 _rockId, bool _rip) {
    require(
      address(retirementManager) == address(0) ||
        retirementManager.isRetirementAllowed(_rockId, _rip)
    );
    _;
  }

  modifier whenTransferAllowed(address _from, address _to, uint256 _rockId) {
    require(
      address(marketplaceManager) == address(0) ||
        marketplaceManager.isTransferAllowed(_from, _to, _rockId)
    );
    _;
  }

  modifier whenEvolvementAllowed(uint256 _rockId, uint256 _newStrength) {
    require(
      address(expManager) == address(0) ||
        expManager.isEvolvementAllowed(_rockId, _newStrength)
    );
    _;
  }

  modifier onlySpawner() {
    require(whitelistedSpawner[msg.sender]);
    _;
  }

  modifier onlyByeSayer() {
    require(whitelistedByeSayer[msg.sender]);
    _;
  }

  modifier onlyMarketplace() {
    require(whitelistedMarketplace[msg.sender]);
    _;
  }

  modifier onlyExpScientist() {
    require(whitelistedExpScientist[msg.sender]);
    _;
  }

  /*
   * @dev Setting the whitelist setter address to `address(0)` would be a irreversible process.
   *  This is to lock changes to TheRocks's contracts after their development is done.
   */
  function setWhitelistSetter(address _newSetter) external onlyWhitelistSetter {
    whitelistSetterAddress = _newSetter;
  }

  function setSpawningManager(address _manager) external onlyWhitelistSetter {
    spawningManager = ITheRocksSpawningManager(_manager);
  }

  function setRetirementManager(address _manager) external onlyWhitelistSetter {
    retirementManager = ITheRocksRetirementManager(_manager);
  }

  function setMarketplaceManager(address _manager) external onlyWhitelistSetter {
    marketplaceManager = ITheRocksMarketplaceManager(_manager);
  }

  function setExpManager(address _manager) external onlyWhitelistSetter {
    expManager = ITheRocksExpManager(_manager);
  }

  function setSpawner(address _spawner, bool _whitelisted) external onlyWhitelistSetter {
    require(whitelistedSpawner[_spawner] != _whitelisted);
    whitelistedSpawner[_spawner] = _whitelisted;
  }

  function setByeSayer(address _byeSayer, bool _whitelisted) external onlyWhitelistSetter {
    require(whitelistedByeSayer[_byeSayer] != _whitelisted);
    whitelistedByeSayer[_byeSayer] = _whitelisted;
  }

  function setMarketplace(address _marketplace, bool _whitelisted) external onlyWhitelistSetter {
    require(whitelistedMarketplace[_marketplace] != _whitelisted);
    whitelistedMarketplace[_marketplace] = _whitelisted;
  }

  function setExpScientist(address _expScientist, bool _whitelisted) external onlyWhitelistSetter {
    require(whitelistedExpScientist[_expScientist] != _whitelisted);
    whitelistedExpScientist[_expScientist] = _whitelisted;
  }
}
