const HttpProvider = require('ethjs-provider-http');
const EthRPC = require('ethjs-rpc');
const ethRPC = new EthRPC(new HttpProvider ('http://localhost:8545'));
const EthQuery = require('ethjs-query');
const ethQuery = new EthQuery(new HttpProvider('http://localhost:8545'));
const BN = require('bn.js');

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
        .then(() => d.setWallet(accounts[1]))
        .then(() => d.merchantWallet.call())
        .then((result) => assert.equal(result, accounts[1], "unexpected merchant wallet address"))
    });  

    //Testing register()
    it("Should register accounts[2] while sending in exact ETH amount", () => 
    {
        let d;
        let sum = registrationFee + storeCredit;

        return Distribute.deployed()
        .then((distr) => d = distr)
        .then(() => d.register({from: accounts[2], value: sum}))
    });

    //Testing register()
    it("Should register accounts[3] while sending in extra ETH", () => 
    {
        let d;
        let extra = 40;
        let sum = registrationFee + storeCredit + extra;
        
        return Distribute.deployed()
        .then((distr) => d = distr)
        .then(() => d.register({from: accounts[3], value: sum}))
    });

    //Testing register()
    it("Should not register accounts[4] while sending in too little ETH", () => 
    {
        let d;

        return Distribute.deployed()
        .then((distr) => d = distr)
        .then(() => d.register({from: accounts[4], value: 0}))
        .catch((error) => console.log("Success: did not allow accounts[4] to register"))
    });

    //Testing startSale()
    it("Should not allow a buyer to start the sale", () => 
    {
        let d;

        return Distribute.deployed()
        .then((distr) => d = distr)
        .then(() => d.startSale.call(8,8,8,8,"1","1",{from: accounts[2]}))
        .catch((error) => console.log("Success: did not allow sale to start"))
    });

    //Testing startSale()
    it("Should allow merchant to start the sale", () => 
    {
        let d;

        return Distribute.deployed()
        .then((distr) => d = distr)
        .then(() => d.startSale.call(8,8,8,8,"1","1",{from: accounts[0]}))
        .then((result) => assert.equal(0,result, "SaleID is wrong"))
    });

    //Testing claimAllowancePts()
    it("Should allow accounts[2] to claim allowance", () => 
    {
        let d;

        return Distribute.deployed()
        .then((distr) => d = distr)
        .then(() => d.claimAllowancePts({from: accounts[2]}))
        .then(() => d.buyers.call(accounts[2]))
        .then((result) => console.log(result))
        // .then((result) => assert.equal(0,result, "SaleID is wrong"))
    });

    //Testing enterSale()
    it("Should allow accounts[2] to claim allowance", () => 
    {
        let d;

        return Distribute.deployed()
        .then((distr) => d = distr)
        .then(() => d.enterSale(10, 0, {from: accounts[2]}))
        .then(() => d.buyers.call(accounts[2]))
        .then((result) => assert.equal(0,result, "SaleID is wrong"))
    });



});