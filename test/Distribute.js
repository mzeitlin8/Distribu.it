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
        .then(() => d.setMerchantWallet(accounts[1]))
        .then(() => d.merchantWallet.call())
        .then((result) => assert.equal(result, accounts[1], "unexpected merchant wallet address"))
    });  

    //Testing register()
    it("Should register accounts[2] while sending in exact ETH amount", () => 
    {
        let d;
        let start_balance;
        let end_balance;
        let sum = registrationFee + storeCredit;
        let sum_str = new BN(sum.toString(10), 10);

        return Distribute.deployed()
        .then((distr) => d = distr)
        .then(() => ethQuery.getBalance(accounts[2]))
        .then((balance) => start_balance = balance.toString(10))
        .then(() => d.register({from: accounts[2], value: sum}))
        .then(() => ethQuery.getBalance(accounts[2]))
        .then((balance) => balance.add(sum_str).toString(10))
        .then((end_balance) => assert.equal(start_balance, end_balance, "accounts[2] has the wrong balance"))
    });

    //Testing register()
    it("Should register accounts[3] while sending in extra ETH", () => 
    {
        let d;
        let start_balance;
        let end_balance;
        let extra = 40;
        let sum = registrationFee + storeCredit;
        let sum_str = new BN(sum.toString(10), 10);

        return Distribute.deployed()
        .then((distr) => d = distr)
        .then(() => ethQuery.getBalance(accounts[3]))
        .then((balance) => start_balance = balance.toString(10))
        .then(() => d.register({from: accounts[3], value: sum + extra}))
        .then(() => ethQuery.getBalance(accounts[3]))
        .then((balance) => balance.add(sum_str).toString(10))
        .then(() => assert.equal(start_balance, end_balance, "accounts[3] has the wrong balance"))
    });

    //Testing register()
    it("Should not register accounts[4] while sending in too little ETH", () => 
    {
        let d;
        let start_balance;
        let end_balance;

        return Distribute.deployed()
        .then((distr) => d = distr)
        .then(() => ethQuery.getBalance(accounts[4]))
        .then((balance) => start_balance = balance.toString(10))
        .then(() => d.register({from: accounts[4], value: 0}))
        .catch((error) => console.log("Success: did not allow accounts[4] to register"))
    });


});