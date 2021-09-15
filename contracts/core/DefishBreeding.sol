// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;

import './ExternalInterfaces/GeneScienceInterface.sol';
import './DefishCore.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";


/// @title A facet of Defish that manages Fish siring, gestation, and birth.
/// @author CauTa (https://defish.io)
/// @dev See the Defish contract documentation to understand how the various contract facets are arranged.
contract DefishBreeding is Ownable, Pausable {
    struct Fish {
        uint256 id;
        uint256 genes;
        uint256 stat;
        uint256 bornAt;
        uint256[2] parents;
        uint16 generation;
        uint256 nextBreed;
        uint8 breedTimes;
    }

    /// @dev A lookup table indicating the cooldown duration after any successful
    ///  breeding action, called "pregnancy time" for matrons and "siring cooldown"
    ///  for sires. Designed such that the cooldown roughly doubles each time a fish
    ///  and over again. Caps out at one week (a fish can breed an unbounded number
    ///  of times, and the maximum cooldown is always seven days).
    uint32[7] public cooldowns = [
        uint32(1 minutes),
        uint32(30 minutes),
        uint32(2 hours),
        uint32(8 hours),
        uint32(16 hours),
        uint32(1 days),
        uint32(3 days)
    ];

    /// @dev A lookup table indicating the breeding fee for any successful breeding action
    ///  Designed such that the fee roughly doubles each time a fish
    ///  is bred, encouraging owners not to just keep breeding the same fish over
    ///  and over again. Caps out at 0.5BNB (a fish can breed an unbounded number
    ///  of times, and the maximum fee is always 0.5BNB).
    uint256[7] public bFee = [2e16, 4e16, 7e16, 11e16, 16e16, 22e16, 50e16];


    DefishCore defishCore;

    /// @dev A mapping from FishIDs to an address that has been approved to use
    ///  this Fish for siring via breedWith(). Each Fish can only have one approved
    ///  address for siring at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public sireAllowedToAddress;

    /// @dev The Egg event is fired when two fishes successfully breed and the produce new egg
    event Egg(uint256 indexed _childId, address indexed owner, uint256 hatchesTime);
    /// @dev The Breed event is fired when two fishes successfully breed
    event Breed(uint256 indexed _matronId, uint256 indexed _sireId, uint256 indexed _childId);

    /// @dev The address of the sibling contract that is used to implement the sooper-sekret
    ///  genetic combination algorithm.
    GeneScienceInterface public geneScience;

    constructor(address core) {
        defishCore = DefishCore(core);
    }

    /// @dev Update the address of the genetic contract, can only be called by the CEO.
    /// @param _address An address of a GeneScience contract instance to be used from this point forward.
    function setGeneScienceAddress(address _address) public onlyOwner {
        GeneScienceInterface candidateContract = GeneScienceInterface(_address);
        require(candidateContract.isGeneScience());
        geneScience = candidateContract;
    }

    function getFish(uint256 _fishId) internal view returns(Fish memory _fish){
        (uint256 genes,
        uint256 stat,
        uint256 bornAt,
        uint256[2] memory parents,
        uint16 generation,
        uint256 nextBreed,
        uint8 breedTimes) = defishCore.getFish(_fishId);
        _fish.id = _fishId;
        _fish.genes = genes;
        _fish.stat = stat;
        _fish.bornAt = bornAt;
        _fish.parents = parents;
        _fish.generation = generation;
        _fish.nextBreed = nextBreed;
        _fish.breedTimes = breedTimes;
    }

    /// @dev Checks that a given fish is able to breed. Requires that the
    ///  current cooldown is finished (for sires) and also checks that there is
    ///  no pending pregnancy.
    function _isReadyToBreed(Fish memory _fish) internal view returns (bool) {
        // In addition to checking the nextBreed, we also need to check to see if
        // the fish has a pending birth; there can be some period of time between the end
        // of the pregnacy timer and the birth event.
        return defishCore.isAliveFish(_fish.id) && (_fish.nextBreed <= block.timestamp);
    }

    /// @dev Check if a sire has authorized breeding with this matron. True if both sire
    ///  and matron have the same owner, or if the sire has given siring permission to
    ///  the matron's owner (via approveSiring()).
    function _isSiringPermitted(uint256 _sireId, uint256 _matronId) internal view returns (bool) {
        address matronOwner = defishCore.ownerOf(_matronId);
        address sireOwner = defishCore.ownerOf(_sireId);

        // Siring is okay if they have same owner, or if the matron's owner was given
        // permission to breed with this sire.
        return (matronOwner == sireOwner || sireAllowedToAddress[_sireId] == matronOwner);
    }

    /// @dev Set the nextBreed for the given Fish, based on its current cooldownIndex.
    ///  Also increments the cooldownIndex (unless it has hit the cap).
    /// @param _fish A reference to the Fish in storage which needs its timer started.
    function _triggerCooldown(Fish memory _fish) internal returns (uint256){
        uint256 cooldown = cooldowns[_fish.breedTimes];
        // Compute the end of the cooldown time (based on current cooldownIndex)
        _fish.nextBreed = uint256(block.timestamp + cooldown);

        // Increment the breeding count, clamping it at 6, which is the length of the
        // cooldowns array. We could check the array size dynamically, but hard-coding
        // this as a constant saves gas. Yay, Solidity!
        if (_fish.breedTimes < 6) {
            _fish.breedTimes += 1;
        }

        defishCore.updateBreedingProfile(_fish.id, _fish.nextBreed, _fish.breedTimes);
        return cooldown;
    }

    /// @notice Grants approval to another user to sire with one of your fishes.
    /// @param _addr The address that will be able to sire with your Fish. Set to
    ///  address(0) to clear all siring approvals for this Fish.
    /// @param _sireId A Fish that you own that _addr will now be able to sire with.
    function approveSiring(address _addr, uint256 _sireId)
        public
        whenNotPaused
    {
        require(defishCore.ownerOf(_sireId) == msg.sender);
        sireAllowedToAddress[_sireId] = _addr;
    }

    /// @notice Checks that a given fish is able to breed
    /// @param _fishId reference the id of the fish, any user can inquire about it
    function isReadyToBreed(uint256 _fishId)
        public
        view
        returns (bool)
    {
        require(_fishId > 0);
        Fish memory _fish = getFish(_fishId);
        return _isReadyToBreed(_fish);
    }

    /// @dev Internal check to see if a given sire and matron are a valid mating pair. DOES NOT
    ///  check ownership permissions (that is up to the caller).
    /// @param _matron A reference to the Fish struct of the potential matron.
    /// @param _sire A reference to the Fish struct of the potential sire.
    function _isValidMatingPair(
        Fish memory _matron,
        Fish memory _sire
    )
        private
        pure
        returns(bool)
    {
        // A Fish can't breed with itself!
        if (_matron.id == _sire.id) {
            return false;
        }

        // fishes can't breed with their parents.
        if (_matron.parents[0] == _sire.id || _matron.parents[1] == _sire.id) {
            return false;
        }
        if (_sire.parents[0] == _matron.id || _sire.parents[1] == _matron.id) {
            return false;
        }

        // We can short circuit the sibling check (below) if either fish is
        // gen zero (has a matron ID of zero).
        if (_sire.parents[0] == 0 || _matron.parents[0] == 0) {
            return true;
        }

        if (_sire.parents[1] == 0 || _matron.parents[1] == 0) {
            return true;
        }

        // fishes can't breed with full or half siblings.
        if (_sire.parents[0] == _matron.parents[0] || _sire.parents[0] == _matron.parents[1]) {
            return false;
        }
        if (_sire.parents[1] == _matron.parents[0] || _sire.parents[1] == _matron.parents[1]) {
            return false;
        }

        // Everything seems cool! Let's get DTF.
        return true;
    }

    /// @dev Internal check to see if a given sire and matron are a valid mating pair for
    ///  breeding via auction (i.e. skips ownership and siring approval checks).
    function _canBreedWithViaAuction(uint256 _matronId, uint256 _sireId)
        public
        view
        returns (bool)
    {
        Fish memory matron = getFish(_matronId);
        Fish memory sire = getFish(_sireId);
        return _isValidMatingPair(matron, sire);
    }

    /// @notice Checks to see if two fishes can breed together, including checks for
    ///  ownership and siring approvals. Does NOT check that both fishes are ready for
    ///  breeding (i.e. breedWith could still fail until the cooldowns are finished).
    ///  TODO: Shouldn't this check pregnancy and cooldowns?!?
    /// @param _matronId The ID of the proposed matron.
    /// @param _sireId The ID of the proposed sire.
    function canBreedWith(uint256 _matronId, uint256 _sireId)
        public
        view
        returns(bool)
    {
        require(_matronId > 0);
        require(_sireId > 0);
        Fish memory matron = getFish(_matronId);
        Fish memory sire = getFish(_sireId);
        return _isValidMatingPair(matron, sire) &&
            _isSiringPermitted(_sireId, _matronId);
    }

    /// @notice Breed a Fish you own (as matron) with a sire that you own, or for which you
    ///  have previously been given Siring approval. Will either make your fish pregnant, or will
    ///  fail entirely.
    /// @param _matronId The ID of the Fish acting as matron (will end up pregnant if successful)
    /// @param _sireId The ID of the Fish acting as sire (will begin its siring cooldown if successful)
    /// @return matron and sire if all the conditions are passed
    function breedCheck(uint256 _matronId, uint256 _sireId) 
        public
        view 
        whenNotPaused
        returns(Fish memory matron, Fish memory sire) {
        // Caller must own the matron.
        require(defishCore.ownerOf(_matronId) == msg.sender, "msg.sender is not owner of matronId!");

        // Neither sire nor matron are allowed to be on auction during a normal
        // breeding operation, but we don't need to check that explicitly.
        // For matron: The caller of this function can't be the owner of the matron
        //   because the owner of a Fish on auction is the auction house, and the
        //   auction house will never call breedWith().
        // For sire: Similarly, a sire on auction will be owned by the auction house
        //   and the act of transferring ownership will have cleared any oustanding
        //   siring approval.
        // Thus we don't need to spend gas explicitly checking to see if either fish
        // is on auction.

        // Check that matron and sire are both owned by caller, or that the sire
        // has given siring permission to caller (i.e. matron's owner).
        // Will fail for _sireId = 0
        require(_isSiringPermitted(_sireId, _matronId), "Siring is not permitted!");

        // Grab a reference to the potential matron
        matron = getFish(_matronId);

        // Make sure matron isn't pregnant, or in the middle of a siring cooldown
        require(_isReadyToBreed(matron), "Matron is not ready to breed!");

        // Grab a reference to the potential sire
        sire = getFish(_sireId);

        // Make sure sire isn't pregnant, or in the middle of a siring cooldown
        require(_isReadyToBreed(sire), "Sire is not ready to breed!");

        // Test that these fishes are a valid mating pair.
        require(_isValidMatingPair(matron, sire), "Invalid matting pair!");
    }

    /// @param matron A Fish ready to give birth.
    /// @param sire A Fish ready to give birth.
    /// @return fishId The Fish ID of the new fish.
    /// @dev Looks at a given Fish and, if pregnant and if the gestation period has passed,
    ///  combines the genes of the two parents to create a new fish. The new Fish is assigned
    ///  to the current owner of the matron. Upon successful completion, both the matron and the
    ///  new fish will be ready to breed again. Note that anyone can call this function (if they
    ///  are willing to pay the gas!), but the new fish always goes to the mother's owner.
    function doBreed(Fish memory matron, Fish memory sire) internal returns (uint256 fishId){
        // Trigger the cooldown for both parents.
        _triggerCooldown(sire);
        // New fish will be delay alive depend on its matron breedTimes
        uint256 delay = _triggerCooldown(matron);

        // Clear siring permission for both parents. This may not be strictly necessary
        // but it's likely to avoid confusion!
        delete sireAllowedToAddress[matron.id];
        delete sireAllowedToAddress[sire.id];

        // Determine the higher generation number of the two parents
        uint16 childGeneration = sire.generation > matron.generation ? sire.generation + 1 : matron.generation + 1;

        // Call the sooper-sekret, sooper-expensive, gene mixing operation.
        uint256 childGenes = geneScience.mixGenes(matron.genes, sire.genes);

        // Make the new fish!
        address owner = defishCore.ownerOf(matron.id);
        fishId = defishCore.spawnFish(childGenes, owner, delay,[matron.id, sire.id], childGeneration);
        emit Egg(fishId, owner, block.timestamp + delay);
        emit Breed(matron.id, sire.id, fishId);
    }

    /// @notice includes a pre-payment of the gas required to call
    /// The required payment is given by breedingFee().
    /// @param _matronId The ID of the Fish acting as matron (will end up pregnant if successful)
    /// @param _sireId The ID of the Fish acting as sire (will begin its siring cooldown if successful)
    function breed(uint256 _matronId, uint256 _sireId)
        public
        payable
        whenNotPaused
        returns (uint256 fishId)
    {
        // Call through the normal breeding flow
        (Fish memory matron, Fish memory sire) = breedCheck(_matronId, _sireId);
        // Check for payment
        uint256 fee = bFee[matron.breedTimes] + bFee[sire.breedTimes];
        require(msg.value >= fee, "Not enough fee!");
        fishId = doBreed(matron, sire);
    }

    function withdraw(uint256 amount) public onlyOwner {
        require(amount < address(this).balance, "WRONG AMOUNT!");
        payable(msg.sender).transfer(amount);
    }
}
