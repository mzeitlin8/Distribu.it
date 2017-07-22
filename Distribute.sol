pragma solidity ^0.4.11;

// hash weight or nah

contract Distribute {

    mapping(address => Buyer) public buyers;
    mapping(uint => Sale) public sales; //saleNonce => sale struct
    // [buyer's address][saleID] => CustomerStatus struct
    mapping(address => mapping(uint => BuyerStatus)) public buyerSaleInfo;

    // variables set and changeable by merchant
    address public merchantWallet;
    address public merchant;
    uint public storeCredit;      // wei
    uint public registrationFee;  // wei
    uint public pitySum;
    uint public allowancePts;
    uint public allowancePeriod;

    // variables to manage allowance system
    uint public allowanceNonce;
    uint public allowanceExp;

    // nonce to differentiate each sale
    uint public saleNonce;

    struct Buyer {
        uint credit;     // wei

        uint pts;
        uint ptsNonce;

        uint pityPts;

        bool registered;
    }

    struct BuyerStatus {
        uint weightPts;  // how much buyer bet to raise chances of winning (default 0)
        bool won;        // whether was able to buy product or not
        bool claimed;    // if won: product claimed    if lost: pity points claimed
    }

    struct Sale {
        uint saleExp;   // for buyers to make enter a sale
        uint claimExp;  // for a winner to claim a product token
        uint price;     // wei
        uint quantity;  // num goods

        address tokenAddr;  // IMPLEMENT
    }

    /*
     * Modifiers
     */
    modifier merchantOnly {
        require(msg.sender == merchant);
        _;
    }
    modifier isRegistered {
        require(buyers[msg.sender].registered);
        _;
    }

    /*
     * Constructor
     */

    function Distribute(address _merchantWallet, 
        uint _storeCredit, 
        uint _registrationFee, 
        uint _pitySum, 
        uint _allowancePts, 
        uint _allowancePeriod) {
        // set merchant variables
        merchantWallet = _merchantWallet;
        storeCredit = _storeCredit;
        registrationFee = _registrationFee;
        pitySum = _pitySum;
        allowancePts = _allowancePts;
        allowancePeriod = _allowancePeriod;
        merchant = msg.sender;

        allowanceNonce = 0;
        allowanceExp = now + _allowancePeriod;

        // start saleID nonce at 0
        saleNonce = 0;
    }

    // is payable automatic?
    function register() payable {
        uint payment = storeCredit + registrationFee;
        uint excess = payment - msg.value;

        // return any excess msg.value
        if (excess > 0) {
            msg.sender.transfer(excess);
        }

        // forward received ether minus any excess to the wallet
        merchantWallet.transfer(payment);

        buyers[msg.sender].credit = storeCredit;
        buyers[msg.sender].registered = true;
    }

    //initialize values in Sale struct and increment sale nonce
    function startSale(uint _salePeriod, uint _claimPeriod, uint _quantity, uint _price) merchantOnly {
        sales[saleNonce].saleExp = now + _salePeriod;
        sales[saleNonce].claimExp = sales[saleNonce].saleExp + _claimPeriod;
        sales[saleNonce].quantity = _quantity;
        sales[saleNonce].price = _price;
        saleNonce++;

        // event
    }

    // called by registered buyer
    // subtract points from the buyer and record points in the sale
    function enterSale(uint _weightPts, uint _saleID) public isRegistered{
        require(!saleEnded(_saleID));
        require(buyers[msg.sender].pts + buyers[msg.sender].pityPts >= _weightPts);

        if (_weightPts > 0) {
            if (buyers[msg.sender].pts >= _weightPts) { // only take from regular pts
                buyers[msg.sender].pts = buyers[msg.sender].pts - _weightPts;
            }
            else { //take all of regular pts and part of pityPts
                uint difference = _weightPts - buyers[msg.sender].pts;
                buyers[msg.sender].pts = 0;
                buyers[msg.sender].pityPts = buyers[msg.sender].pityPts - difference;
            }
        }
        // record how many points the buyer wants to put into the sale
        buyerSaleInfo[msg.sender][_saleID].weightPts = _weightPts;
    }

    // intended to be called by merchant, but it is fine if anyone does
    function decideWinners(uint _saleID) {
        require(saleEnded(_saleID));
        // require( hasn't been decided yet )
        // call an oracle
        // event
        // set whether buyers won or lost in struct
    }

    // called by losers of the sale
    // increase number of pity points
    function claimPityPts(uint _saleID) publilc isRegistered {
        require(buyerSaleInfo[msg.sender][_saleID].claimed == false); //cannot claim twice
        require(buyerSaleInfo[msg.sender][_saleID].won == false); //is loser

        buyers[msg.sender].pityPts += pitySum;
        buyerSaleInfo[msg.sender][_saleID].claimed = true;
    }

    // called by winners of the sale, send ETH with txn to pay for product
    // get token from merchant
    function claimProduct(uint _saleID) public isRegistered payable {
        require(sales[_saleID].claimExp >= now);
        require(buyerSaleInfo[msg.sender][_saleID].claimed == false); //cannot claim twice
        require(buyerSaleInfo[msg.sender][_saleID].won == true); //is winner
         
        uint excess = sales[_saleID].price - msg.value;

        // return any excess msg.value
        if (excess > 0) {
            msg.sender.transfer(excess);
        }

        // forward received ether minus any excess to the wallet
        merchantWallet.transfer(sales[_saleID].price);

        // GIVE TOKEN, IMPLEMENT

        buyerSaleInfo[msg.sender][_saleID].claimed == true;
    }

    //called by registered buyers
    function claimAllowancePts() isRegistered{
        if (allowanceExp < now) { // allowance expiry has passed
            allowanceExp += allowancePeriod;
            allowanceNonce++;
        }

        require(allowanceNonce > buyers[msg.sender].ptsNonce);
        buyers[msg.sender].ptsNonce = allowanceNonce;
        buyers[msg.sender].pts = allowancePts;
    }


    /*
     * Helper Functions
     */
     function saleEnded(uint saleID) private returns(bool) {
        return sales[_saleID].saleExp < now;
     }

    /*
     * Merchant Functions
     */

    function setMerchantAddress(address _addr) public merchantOnly {
        merchant = _addr;
    }

    function setMerchantWallet(address _addr) public merchantOnly {
        merchantWallet = _addr;
    }

    function setStoreCredit(uint _credit) public merchantOnly {
        storeCredit = _credit;
    }

    function setRegistrationFee(uint _fee) public merchantOnly{
        registrationFee = _fee;
    }
    
    function setPitySum(uint _sum) public merchantOnly{
        pitySum = _sum;
    }

    function setAllowancePts(uint _pts) public merchantOnly{
        registrationFee = _pts;
    }
    
    function setAllowancePeriod(uint _period) public merchantOnly{
        pitySum = _period;
    }


}