// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;


import "./DefishBase.sol";


// solium-disable-next-line no-empty-blocks
contract DefishCore is DefishBase {
  struct Fish {
    uint256 genes;
    uint256 stat;
    uint256 bornAt;
    uint256[2] parents;
    uint16 generation;
    uint256 nextBreed;
    uint8 breedTimes;
  }

  Fish[] public fishes;

  event FishSpawned(uint256 indexed _fishId, address indexed _owner, uint256 _genes, uint256 _stat, uint256 _bornAt, uint256[2] _parents, uint16 _generation);
  event FishEvolved(uint256 indexed _fishId, uint256 _oldStat, uint256 _newStat);
  event FishRebirthed(uint256 indexed _fishId, uint256 _genes);
  event FishRetired(uint256 indexed _fishId);

  modifier isValidFish(uint256 _tokenId) {
    require(_exists(_tokenId));
    _;
  }

  constructor() DefishBase() {
    uint256[2] memory parents = [uint256(0), uint256(0)];
    fishes.push(Fish(0, ~uint256(0), block.timestamp, parents, 0, 0, 0)); // The void Fish with super power
  }

  function getFish(
    uint256 _fishId
  )
    external
    view
    isValidFish(_fishId)
    returns (
      uint256 genes, 
      uint256 stat, 
      uint256 bornAt, 
      uint256[2] memory parents, 
      uint16 generation,
      uint256 nextBreed,
      uint8 breedTimes)
  {
    Fish storage _fish = fishes[_fishId];
    return (_fish.genes, _fish.stat, _fish.bornAt, _fish.parents, _fish.generation, _fish.nextBreed, _fish.breedTimes);
  }

  function spawnFish(
    uint256 _genes,
    address _owner,
    uint256 delay,
    uint256[2] memory parents,
    uint16 generation
  )
    external
    onlySpawner
    whenSpawningAllowed(_genes, _owner)
    returns (uint256 _fishId)
  {
    return _spawnFish(_genes, _owner, delay, parents, generation);
  }

  function _spawnFish(
    uint256 _genes,
    address _owner,
    uint256 delay,
    uint256[2] memory parents,
    uint16 generation
  )
    internal
    returns (uint256 _fishId)
  {
    Fish memory _fish = Fish(_genes, 0, block.timestamp + delay, parents, generation, 0, 0);
    fishes.push(_fish);
    _fishId = fishes.length - 1;
    _mint(_owner, _fishId);
    emit FishSpawned(_fishId, _owner, 
                    fishes[_fishId].genes, 
                    fishes[_fishId].stat, 
                    fishes[_fishId].bornAt, 
                    fishes[_fishId].parents, 
                    fishes[_fishId].generation);
  }

  function evolveFish(
    uint256 _fishId,
    uint256 _newStat
  )
    external
    onlyStatScientist
    isValidFish(_fishId)
    whenEvolvementAllowed(_fishId, _newStat)
  {
    Fish storage _fish = fishes[_fishId];
    uint256 _oldStat = _fish.stat;
    fishes[_fishId].stat = _newStat;
    emit FishEvolved(_fishId, _oldStat, _newStat);
  }

  function rebirthFish(
    uint256 _fishId,
    uint256 _genes,
    uint256 delay
  )
    external
    onlySpawner
    isValidFish(_fishId)
    whenRebirthAllowed(_fishId, _genes)
  {
    Fish storage fish = fishes[_fishId];
    fish.genes = _genes;
    fish.bornAt = block.timestamp + delay;
    emit FishRebirthed(_fishId, _genes);
  }

  function retireFish(
    uint256 _fishId,
    bool _rip
  )
    external
    onlyByeSayer
    whenRetirementAllowed(_fishId, _rip)
  {
    _burn(_fishId);

    if (_rip) {
      delete fishes[_fishId];
    }

    emit FishRetired(_fishId);
  }


  function isAliveFish(uint256 _fishId) public view returns (bool){
    return fishes[_fishId].genes != 0 && fishes[_fishId].bornAt != 0 && fishes[_fishId].bornAt <= block.timestamp;
  }

  function updateBreedingProfile(uint256 _fishId, uint256 _nextBreed, uint8 _breedTimes) public onlySpawner {
    fishes[_fishId].nextBreed = _nextBreed;
    fishes[_fishId].breedTimes = _breedTimes;
  }
}
