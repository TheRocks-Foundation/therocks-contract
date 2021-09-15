// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;


import "./DefishManager.sol";


contract DefishDependency {
  address public whitelistSetterAddress;

  IDefishSpawningManager public spawningManager;
  IDefishRetirementManager public retirementManager;
  IDefishMarketplaceManager public marketplaceManager;
  IDefishStatManager public statManager;

  mapping (address => bool) public whitelistedSpawner;
  mapping (address => bool) public whitelistedByeSayer;
  mapping (address => bool) public whitelistedMarketplace;
  mapping (address => bool) public whitelistedStatScientist;

  constructor() {
    whitelistSetterAddress = msg.sender;
  }

  modifier onlyWhitelistSetter() {
    require(msg.sender == whitelistSetterAddress);
    _;
  }

  modifier whenSpawningAllowed(uint256 _genes, address _owner) {
    require(
      spawningManager == IDefishSpawningManager(address(0)) ||
        spawningManager.isSpawningAllowed(_genes, _owner)
    );
    _;
  }

  modifier whenRebirthAllowed(uint256 _fishId, uint256 _genes) {
    require(
      address(spawningManager) == address(0) ||
        spawningManager.isRebirthAllowed(_fishId, _genes)
    );
    _;
  }

  modifier whenRetirementAllowed(uint256 _fishId, bool _rip) {
    require(
      address(retirementManager) == address(0) ||
        retirementManager.isRetirementAllowed(_fishId, _rip)
    );
    _;
  }

  modifier whenTransferAllowed(address _from, address _to, uint256 _fishId) {
    require(
      address(marketplaceManager) == address(0) ||
        marketplaceManager.isTransferAllowed(_from, _to, _fishId)
    );
    _;
  }

  modifier whenEvolvementAllowed(uint256 _fishId, uint256 _newStrength) {
    require(
      address(statManager) == address(0) ||
        statManager.isEvolvementAllowed(_fishId, _newStrength)
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

  modifier onlyStatScientist() {
    require(whitelistedStatScientist[msg.sender]);
    _;
  }

  /*
   * @dev Setting the whitelist setter address to `address(0)` would be a irreversible process.
   *  This is to lock changes to Defish's contracts after their development is done.
   */
  function setWhitelistSetter(address _newSetter) external onlyWhitelistSetter {
    whitelistSetterAddress = _newSetter;
  }

  function setSpawningManager(address _manager) external onlyWhitelistSetter {
    spawningManager = IDefishSpawningManager(_manager);
  }

  function setRetirementManager(address _manager) external onlyWhitelistSetter {
    retirementManager = IDefishRetirementManager(_manager);
  }

  function setMarketplaceManager(address _manager) external onlyWhitelistSetter {
    marketplaceManager = IDefishMarketplaceManager(_manager);
  }

  function setStatManager(address _manager) external onlyWhitelistSetter {
    statManager = IDefishStatManager(_manager);
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

  function setStatScientist(address _statScientist, bool _whitelisted) external onlyWhitelistSetter {
    require(whitelistedStatScientist[_statScientist] != _whitelisted);
    whitelistedStatScientist[_statScientist] = _whitelisted;
  }
}
