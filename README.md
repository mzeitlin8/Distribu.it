# Distribu.it

## Purpose
A platform for the fair sale of highly-valued goods.

## User Process
A description of the user process at each step and how the backend handles it.

1.  A merchant creates the contract.  The merchant has an amount of control over the parameters of the contract's creation,
    such as the registration fee and the wallet they want to use.  The merchant is also able to edit contract-wide parameters
    at any time.

2.  The merchant can create sales at any time, and there can be multiple sales at once.  Each sale has its own ID and its 
    own token created to represent the product being sold.

3.  To register, a customer sends in registration fee.  A portion of the registration fee is saved for the customer to use as 
    store credit if they win a product, and a portion goes to the merchant's wallet.

4.  The customer is now able to claim an allowance of points.  These points can be spent on sales to weight the customer's
    vote, allowing a customer to put preference to certain products over others.  The points refresh back to a set value after
    a set time period (controlled by the merchant's parameters).

5.  The customer can enter sales by specifying the number of points they wish to use.

6.  The merchant calls an oracle (WolframAlpha's random number generator through Oraclize) to decide the winners.

7.  Winners may now buy the token that represents the product being sold.

8.  Losers can claim an amount of "pity points" specified by the merchant.  Pity points can be used as regular points
    to give customers a better chance of winning a sale, but they persist indefinitely rather than resetting after a certain
    period of time like the regular allowance of points does.

9.  Outside this contract, winners can resell their tokens on the market or trade them to the merchant for the actual product.

## Design Notes and Considerations

1.  The merchant is expected to choose their parameters fairly for the contracts and sales and to not cheat customers
    because this product is intended for respected and trusted merchants who would want to take the hit that scamming
    customers would result in.
    
2.  The merchant is expected to pay the gas (and oracle costs, which typically cost $0.03 USD per call to Wolfram Alpha) 
    needed to run the decideWinners function that randomizes the customers who recieve the right to buy the good.  To
    offset this cost and other costs of running the contract, the merchant is recieving a portion of the registration fee of 
    each customer.  Addtionally, they are saving the money that having their site DDoS'd by bots would lose.
    

