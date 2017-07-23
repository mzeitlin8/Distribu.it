var Distribute = artifacts.require("./Distribute.sol");
var merchantWallet = 40000;
var storeCredit = 20;
var registrationFee = 40;
var pitySum = 2;
var allowancePts = 50;
var allowancePeriod = 100;

module.exports = function(deployer) {
  deployer.deploy(Distribute, 
        merchantWallet, 
        storeCredit, 
        registrationFee, 
        pitySum, 
        allowancePts, 
        allowancePeriod);
};
