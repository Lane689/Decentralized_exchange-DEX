// SPDX-License-Identifier: MIT
pragma solidity >0.6.0 <0.9.0;
pragma experimental ABIEncoderV2;
import "./wallet.sol";

contract Dex is Wallet {
    using SafeMath for uint256;

    enum Side{
        BUY,
        SELL
    }

    struct Order{
        uint id;
        address trader;
        Side side;
        bytes32 ticker;
        uint amount;
        uint price;
        uint filled;
    }

    uint nextOrderID = 0;
    mapping(bytes32 => mapping(uint => Order[])) public orderBook; // uint will be 0 or 1 and 0 is BUY, 1 is SELL from enum and that point to 
                                                            // it's own orderbook for each asset

    function getOrderBook(bytes32 ticker, Side side) view public returns(Order[] memory) {
        return orderBook[ticker][uint(side)];
    }

    function createLimitOrder(Side side, bytes32 ticker, uint amount, uint price) public {
        if(side == Side.BUY){
            require(balances[msg.sender]["ETH"] >= amount.mul(price)); 
        }
        else if(side == Side.SELL){
            require(balances[msg.sender][ticker] >= amount);
        }

        Order[] storage orders = orderBook[ticker][uint(side)];
        orders.push(Order(nextOrderID, msg.sender, side, ticker, amount, price, 0));
        uint i = orders.length > 0 ? orders.length-1 : 0; // ako je array empty -> tada i = 0

        if (side == Side.BUY){
            while(i > 0){
                if(orders[i-1].price > orders[i].price){
                    break;
                }
                Order memory orderToMove = orders[i-1];
                orders[i-1] = orders[i];
                orders[i] = orderToMove;
                i--; 
            }   
        }

        else if (side == Side.SELL){
            while(i > 0){
                if(orders[i-1].price < orders[i].price){
                    break;
                }
                Order memory orderToMove = orders[i-1];
                orders[i-1] = orders[i];
                orders[i] = orderToMove;
                i--; 
            }
        }

    nextOrderID++;
    }

    function crateMarketOrder(Side side, bytes32 ticker, uint amount) public {
        if(side == Side.SELL){
            require(balances[msg.sender][ticker] >= amount, "Insuffient balance");
        }

        uint orderBookSide; 
        if(side == Side.BUY){ // if we want make buy order, we need to match to the sell side of orderbook 
            
            orderBookSide = 1; // Sell -> 1
        }
        else{
            orderBookSide = 0; // Buy -> 0
        }   

        Order[] storage orders = orderBook[ticker][orderBookSide];

        uint totalFilled = 0; 

        // loop take us in the orderbook
        for(uint i=0; i< orders.length || totalFilled < amount; i++){ // exit from loop ako i dođe do kraja (orders.length) ili ako popunimo cijeli order 
            uint leftToFill = amount.sub(totalFilled); //100 |||| 200 
            uint availableToFill = orders[i].amount.sub(orders[i].filled); //200 |||| 100
            uint filled = 0; 

            if(availableToFill > leftToFill){
                filled = leftToFill;  // fill entire market order
            }
            else{
                filled = availableToFill;  // fill as much as is available in order[i]
            }
            totalFilled = totalFilled.add(filled);
            orders[i].filled = orders[i].filled.add(filled);
            uint cost = filled.mul(orders[i].price);

            if(side == Side.BUY){
                require(balances[msg.sender]["ETH"] >= filled.mul(orders[i].price)); // require buyer has enoguh balance to cover the purchase
                // Execute the trade
                balances[msg.sender]["ETH"] = balances[msg.sender]["ETH"].sub(cost);
                balances[msg.sender][ticker] = balances[msg.sender][ticker].add(filled); 

                balances[orders[i].trader][ticker] = balances[orders[i].trader][ticker].sub(filled);
                balances[orders[i].trader]["ETH"] = balances[orders[i].trader]["ETH"].add(cost);
            }
            else if(side == Side.SELL){
                balances[msg.sender]["ETH"] = balances[msg.sender]["ETH"].add(cost);
                balances[msg.sender][ticker] = balances[msg.sender][ticker].sub(filled);

                balances[orders[i].trader][ticker] = balances[orders[i].trader][ticker].add(filled);
                balances[orders[i].trader]["ETH"] = balances[orders[i].trader]["ETH"].sub(cost);
            }
        }
        // Rremove 10% filled orders
        while(orders.length > 0 && orders[0].filled == orders[0].amount ){
            // remove the top element in the orders array by overwriting every element with the next element in the order list
            for( uint i = 0; i < orders.length - 1; i++){
                orders[i] = orders[i+1];
            }
            orders.pop();
        }
          
    }
}