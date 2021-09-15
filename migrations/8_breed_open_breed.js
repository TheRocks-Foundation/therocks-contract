const DefishBreeding = artifacts.require('DefishBreeding');
const DefishCore = artifacts.require("DefishCore");
const GeneScience = artifacts.require('GeneScienceV1');


module.exports = async function (deployer, network, accounts) {
    let core = await DefishCore.at(DefishCore.address);
    let breeder = await DefishBreeding.at(DefishBreeding.address);
    let genes = await GeneScience.at(GeneScience.address);

    let matronId = 6;
    let sireId = 7;

    let result = breeder.breedCheck(matronId, sireId);
    console.log("Breed check for fish-6 and fish-7: \n");
    console.log(result);

    let matron = await core.getFish(matronId);
    let sire = await core.getFish(sireId);
    // console.log(matron);
    // console.log(sire);

    let fee1 = await breeder.bFee(matron[6]);
    let fee2 = await breeder.bFee(sire[6]);
    let fee = fee1.add(fee2);
    console.log("Breeding Fee: " + fee);
    
    let tx = await breeder.breed(matronId, sireId, {value:  fee});
    console.log("Do breed: \n" + tx);
};