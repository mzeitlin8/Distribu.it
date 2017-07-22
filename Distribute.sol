pragma solidity ^0.4.11;

// implement ether library in all ether variables
// hash weight or nah

contract Distribute {

	mapping(address => Customer) public buyers;
	mapping(uint => Sale) public sales;
	// holds buyer information for a single sale  
	// usage: [buyer's address][saleID] => CustomerStatus struct
	mapping(address => mapping(uint => CustomerStatus)) public buyerSaleInfo;

	// variables set and changeable by merchant
	address public merchantWallet;
	address public merchant;
	uint public storeCredit;      // ether
	uint public registrationFee;  // ether
	uint public pitySum;
	uint public allowancePts;
	uint public allowancePeriod;

	// nonce to differentiate each sale
	uint public saleNonce;

	struct Customer {
		uint credit;     // ether
		uint pts;
		uint pityPts;
		bool registered;
	}

	struct CustomerStatus {
		uint weightPts;  // how much buyer bet to raise chances of winning (default 0)
		bool won;        // whether was able to buy product or not
		bool claimed;    // if won: product claimed    if lost: pity points claimed
	}

	struct Sale {
		uint saleExp;
		uint claimExp;   // IMPLEMTNT
		uint price;      // ether
		uint quantity;

		address tokenAddr;  // IMPLEMENT
	}

	/*
	 * Modifier
	 */

	// merchantOnly


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

		// start saleID nonce at 0
		saleNonce = 0;
	}

	// is payable automatic?
	function register() payable {
		uint payment = storeCredit + registrationFee;
		// make sure they sent payment in ether and provide change use mike's sale
		// ether goes into merchant wallet

		buyers[msg.sender].credit = storeCredit;
		buyers[msg.sender].registered = true;
	}

	function startSale(uint _salePeriod, uint _quantity, uint _price) merchantOnly {
		sales[saleNonce].saleExp = now + _salePeriod;
		sales[saleNonce].quantity = _quantity;
		sales[saleNonce].price = _price;
		saleNonce++;

		// event
	}

	function enterSale(uint _weightPts, uint _saleID) {
		//
		require(buyers[msg.sender].registered == true);
		require(buyers[msg.sender].pts + buyers[msg.sender].pityPts >= _weightPts);

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
	function decide(uint _saleID) {
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
		require(buyerSaleInfo[msg.sender][_saleID].claimed == false);
		require(buyerSaleInfo[msg.sender][_saleID].won == true);
		// make sure paid correct amount and give change
		// GIVE TOKEN, IMPLEMENT

		buyerSaleInfo[msg.sender][_saleID].claimed == true;
	}

	function resetPts



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

	function setStoreCredit(uint _storeCredit) public merchantOnly {
		storeCredit = _storeCredit;
	}

	function setRegistrationFee(uint _fee) public merchantOnly{
		registrationFee = _fee;
	}
	
	function setPitySum(uint _pitySum) public merchantOnly{
		pitySum = _pitySum;
	}




}