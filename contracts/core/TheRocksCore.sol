// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;


import "./TheRocksBase.sol";


// solium-disable-next-line no-empty-blocks
contract TheRocksCore is TheRocksBase {
  struct Rock {
    uint256 character;
    uint256 exp;
    uint256 bornAt;
    uint8 level;
  }

  Rock[] public rocks;

  event RockSpawned(uint256 indexed _rockId, address indexed _owner, uint256 _character, uint256 _exp, uint256 _bornAt, uint8 _level);
  event RockEvolved(uint256 indexed _rockId, uint256 _newCharacter, uint256 _newExp, uint8 _newLevel);
  event RockRebirthed(uint256 indexed _rockId, uint256 _character);
  event RockRetired(uint256 indexed _rockId);

  modifier validateRock(uint256 _tokenId) {
    require(_exists(_tokenId));
    _;
  }

  constructor() TheRocksBase() {
    rocks.push(Rock(0, ~uint256(0), block.timestamp, ~uint8(0))); // The void Rock with super power
  }

  function getRock(
    uint256 _rockId
  )
    external
    view
    validateRock(_rockId)
    returns (
      uint256 character, 
      uint256 exp, 
      uint256 bornAt,
      uint8 level)
  {
    Rock storage _rock = rocks[_rockId];
    return (_rock.character, _rock.exp, _rock.bornAt, _rock.level);
  }

  function spawnRock(
    uint256 _character,
    address _owner,
    uint256 delay
  )
    external
    onlySpawner
    whenNotPaused
    whenSpawningAllowed(_character, _owner)
    returns (uint256 _rockId)
  {
    return _spawnRock(_character, _owner, delay);
  }

  function _spawnRock(
    uint256 _character,
    address _owner,
    uint256 delay
  )
    internal
    returns (uint256 _rockId)
  {
    Rock memory _rock = Rock(_character, 0, block.timestamp + delay, 0);
    rocks.push(_rock);
    _rockId = rocks.length - 1;
    _mint(_owner, _rockId);
    emit RockSpawned(_rockId, _owner, 
                    rocks[_rockId].character, 
                    rocks[_rockId].exp, 
                    rocks[_rockId].bornAt,
                    rocks[_rockId].level);
  }

  function evolveRock(
    uint256 _rockId,
    uint256 _advanceCharacter,
    uint256 _newExp,
    uint8 _newLevel
  )
    external
    whenNotPaused
    onlyExpScientist
    validateRock(_rockId)
    whenEvolvementAllowed(_rockId, _newExp)
  {
    Rock storage _rock = rocks[_rockId];
    _rock.character = _advanceCharacter;
    _rock.exp = _newExp;
    _rock.level = _newLevel;
    emit RockEvolved(_rockId, _rock.character, _rock.exp, _rock.level);
  }

  function rebirthRock(
    uint256 _rockId,
    uint256 _character,
    uint256 delay
  )
    external
    whenNotPaused
    onlySpawner
    validateRock(_rockId)
    whenRebirthAllowed(_rockId, _character)
  {
    Rock storage rock = rocks[_rockId];
    rock.character = _character;
    rock.bornAt = block.timestamp + delay;
    emit RockRebirthed(_rockId, _character);
  }

  function retireRock(
    uint256 _rockId,
    bool _rip
  )
    external
    whenNotPaused
    onlyByeSayer
    whenRetirementAllowed(_rockId, _rip)
  {
    _burn(_rockId);

    if (_rip) {
      delete rocks[_rockId];
    }

    emit RockRetired(_rockId);
  }


  function isValidRock(uint256 _rockId) public view returns (bool){
    return rocks[_rockId].character != 0 && rocks[_rockId].bornAt != 0 && rocks[_rockId].bornAt <= block.timestamp;
  }
}
