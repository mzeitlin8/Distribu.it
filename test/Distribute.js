const HttpProvider = require('ethjs-provider-http');
const EthRPC = require('ethjs-rpc');
const ethRPC = new EthRPC(new HttpProvider ('http://localhost:8545'));
const EthQuery = require('ethjs-query');
const ethQuery = new EthQuery(new HttpProvider('http://localhost:8545'));

var Distribute = artifacts.require("./Distribute.sol");
// Constants
var merchantWallet = 40000;
var storeCredit = 20;
var registrationFee = 40;
var pitySum = 2;
var allowancePts = 50;
var allowancePeriod = 100;

contract('Distribute', (accounts) =>
{
    it("Should say merchant address is accounts[0]", () => 
    {
        let d;
        return Distribute.deployed()
        .then((distr) => d = distr)
        .then(() => d.merchant.call())
        .then((result) => assert.equal(result, accounts[0], "unexpected merchant address"))
    });

    //Testing setMerchantWallet()
    it("Should set merchant wallet to accounts[1]", () => 
    {
        let d;
        return Distribute.deployed()
        .then((distr) => d = distr)
        .then(() => d.setMerchantWallet(accounts[1]))
        .then(() => d.merchantWallet.call())
        .then((result) => assert.equal(result, accounts[1], "unexpected merchant wallet address"))
    });  

    //Testing register()
    it("Should register accounts[2] while sending in exact ETH amount", () => 
    {
        let d;
        return Distribute.deployed()
        .then((distr) => d = distr)
        .then((balance) => console.log(balance.toString(10)))
        .then(() => d.register({from: accounts[2], 
                                value: registrationFee + storeCredit}))
    });

});