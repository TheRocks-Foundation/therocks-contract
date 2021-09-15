// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;

import './ExternalInterfaces/GeneScienceInterface.sol';
import './DefishCore.sol';
import "@openzeppelin/contracts/access/Ownable.sol";

contract DefishRandomSpawning is Ownable {
    event CreateFish(address owner, uint256 _matronId, uint256 _sireId, uint256 _childId, uint256 hatchesTime);
    
    DefishCore defishCore;
    GeneScienceInterface geneScience;

    uint32 public total = 100000;
    uint32 public generated = 0;

    constructor(address core) {
        defishCore = DefishCore(core);
    }

    function setGeneScienceAddress(address _address) public onlyOwner {
        GeneScienceInterface candidateContract = GeneScienceInterface(_address);
        require(candidateContract.isGeneScience());
        geneScience = candidateContract;
    }

    function _createFish()
        private
        returns (uint256 fishId)
    {
        require(generated <= total, "Reach maximum Fish!");
        generated = generated + 1;
        uint256 childGenes = geneScience.randomeGene(generated);
        fishId = defishCore.spawnFish(childGenes, msg.sender, 0,[uint256(0), uint256(0)], 0);
        emit CreateFish(msg.sender, 0, 0, fishId, block.timestamp);
    }

    function createFish()
        public
        onlyOwner
        returns (uint256 fishId)
    {
        return _createFish();
    }

    function createMultiFish(uint8 amount)
        public
        onlyOwner
    {
        require(amount <= 50, "You can only create max 50 Fishes per transaction");
        for (uint8 i; i < amount; i++) {
            _createFish();
        }
    }

    function withdraw(uint256 amount) public onlyOwner {
        require(amount < address(this).balance, "WRONG AMOUNT!");
        payable(msg.sender).transfer(amount);
    }
}
