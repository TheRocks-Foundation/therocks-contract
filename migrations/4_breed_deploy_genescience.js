const GeneScience = artifacts.require('GeneScience');
const GeneScienceV1 = artifacts.require('GeneScienceV1');

module.exports = function (deployer, network, accounts) {
    // deployer.deploy(GeneScience, { from: accounts[0], overwrite: true });
    deployer.deploy(GeneScienceV1, { from: accounts[0], overwrite: true });
}