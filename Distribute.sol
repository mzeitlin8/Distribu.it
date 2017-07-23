pragma solidity ^0.4.11;
import "oraclizeAPI_04.sol";
import "HumanStandardToken.sol";




contract Distribute is usingOraclize {

	mapping(address => Customer) public buyers;
	mapping(uint => Sale) public sales;
	// holds buyer information for a single sale  
	// usage: [buyer's address][saleID] => CustomerStatus struct
	mapping(address => mapping(uint => CustomerStatus)) public buyerSaleInfo;

	// variables set and changeable by merchant
	address public merchantWallet; // wallet where merchant recieves ether and tokens
	address public merchant;       // merchant's address that calls functions
	uint public storeCredit;       // in wei
	uint public registrationFee;   // in wei
	uint public pitySum;
	uint public allowancePts;
	uint public allowancePeriod;

	// variables to manage allowance system
	uint public allowanceNonce;
	uint public allowanceExp;

	// nonce to differentiate each sale
	uint public saleNonce;

	struct Customer {
		uint credit;     // in wei
		uint pts;
		uint ptsNonce;
		uint pityPts;
		bool registered;
	}

	struct CustomerStatus {
		uint weightPts;  // how much buyer bet to raise chances of winning (default 0)
		bool won;        // whether was able to buy product or not
		bool claimed;    // if won: product claimed    if lost: pity points claimed
	}

	struct Sale {
		uint saleExp;    // sale end time
		uint claimExp;   // claiming period end time
		uint price;      // in wei
		uint quantity;   // also serves as a counter for how many tokens of the product have been claimed

		// instance of the token that represents the product
		HumanStandardToken token;  
	}

	/*
	 * Modifiers
	 */

	modifier merchantOnly {
        require(msg.sender == merchant);
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

	function startSale(uint _salePeriod, uint _claimPeriod, uint _quantity, uint _price, uint _tokenName, uint _tokenID) merchantOnly {
		sales[saleNonce].saleExp = now + _salePeriod;
		sales[saleNonce].claimExp = sales[saleNonce].saleExp + _claimPeriod;
		sales[saleNonce].quantity = _quantity;
		sales[saleNonce].price = _price;
		saleNonce++;

		// create a token for the product
		sales[saleNonce].token = new HumanStandardToken(_quantity, _tokenName, 0, _tokenID);

		// event
	}

	function enterSale(uint _weightPts, uint _saleID) {
		//
		require(buyers[msg.sender].registered == true);
		require(buyers[msg.sender].pts + buyers[msg.sender].pityPts >= _weightPts);
		require(sales[_saleID].saleExp > now);

		if (_weightPts > 0) {
			if (buyers[msg.sender].pts >= _weightPts) {
				buyers[msg.sender].pts = buyers[msg.sender].pts - _weightPts;
			}
			else
			{
				uint difference = _weightPts - buyers[msg.sender].pts;
				buyers[msg.sender].pts = 0;
				buyers[msg.sender].pityPts = buyers[msg.sender].pityPts - difference;
			}
		}

		buyerSaleInfo[msg.sender][_saleID].weightPts = _weightPts;
	}

	// intended to be called by merchant, but it is fine if anyone does
	function decideWinners(uint _saleID) {
		require(sales[_saleID].saleExp < now);
		require( hasn't been decided yet )
		// call an oracle
		// event
		// set whether buyers won or lost in struct
	}

	function claimPityPts(uint _saleID) {
		require(buyerSaleInfo[msg.sender][_saleID].claimed == false);
		require(buyerSaleInfo[msg.sender][_saleID].won == false);

		buyers[msg.sender].pityPts += pitySum;
		buyerSaleInfo[msg.sender][_saleID].claimed = true;
	}

	function claimProduct(uint _saleID) payable {
		require(sales[_saleID].claimExp >= now);
		require(buyerSaleInfo[msg.sender][_saleID].claimed == false);
		require(buyerSaleInfo[msg.sender][_saleID].won == true);

		uint price = sales[_saleInfo].price;

		// let buyer pay with store credit if they have any
		if (buyer[msg.sender].credit > 0) {
			// less store credit than cost
			if (buyer[msg.sender].credit <= price) {
				price -= buyer[msg.sender].credit;
				buyer[msg.sender].credit = 0;
			}
			// more store credit than cost
			else {
				buyer[msg.sender].credit -= price;
				price = 0;
			}
		}
		 
		uint excess = price - msg.value;

        // return any excess msg.value
        if (excess > 0) {
            msg.sender.transfer(excess);
        }

        // forward received ether minus any excess to the wallet
        merchantWallet.transfer(payment);

		// give product token
		HumanStandardToken tok = sales[_saleID].token;
		require(tok.transfer(msg.sender, 1));
		sales[_saleID].quantity--;

		buyerSaleInfo[msg.sender][_saleID].claimed == true;
	}

	// allows merchant to claim any unclaimed product tokens
	function claimExtraTokens(uint _saleID) {
		require(sales[_saleID].claimExp < now);
		HumanStandardToken tok = sales[_saleID].token;
		require(tok.transfer(merchantWallet, sales[_saleID].quantity));
		sales[_saleID].quantity = 0;
	}

	function claimAllowancePts() {
		// increment to next allowance period if current has ended
		if (allowanceExp < now) {
			allowanceExp += allowancePeriod;
			allowanceNonce++;
		}

		// check if allowance has been claimed for this period
		require(allowanceNonce > buyers[msg.sender].pityNonce);
		buyers[msg.sender].ptsNonce = allowanceNonce;
		buyers[msg.sender].pts = allowancePts;
	}



	/*
	 * Merchant Functions
	 */

	// changes the address that can use merchantOnly functions
	function setAddress(address _addr) public merchantOnly {
		merchant = _addr;
	}

	function setWallet(address _addr) public merchantOnly {
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