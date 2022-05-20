//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
import "./Wallet.sol";






contract Dex is Wallet{
    
    mapping(address => uint256) ethbalances;
    event newOrder(uint id, address trader, Side side, string symbol, uint amount, uint price );
    constructor() Wallet(msg.sender){}
    enum Side{
        BUY,
        SELL
    }
    
    struct Order{
        uint id;
        address trader;
        Side side;
        string symbol;
        uint amount;
        uint price;
        uint filled;

    }

    uint counter =0;

    function depositETH() public payable{
        ethbalances[msg.sender]+=msg.value;

    }
    function withdrawETH(uint amount) public{
        require(ethbalances[msg.sender]>=amount);
        ethbalances[msg.sender]-=amount;
        payable(msg.sender).transfer(amount);


    }

    mapping(string => mapping(uint=> Order[])) orderBook;

    function getOrderBook(string memory symbol, Side side) public view returns(Order[] memory) {
        return orderBook[symbol][uint(side)];

    }

    function ETHbalanceOf(address _address)public view returns(uint256){
        return ethbalances[_address];

    }

    function createLimitOrder(Side side, string memory symbol, uint amount , uint price) public {
        if(side == Side.BUY){
            require(ethbalances[msg.sender]>= amount*price);
        }
        else if(side == Side.SELL){
            require(tokenBalances[msg.sender][symbol] >= amount);
        }
        
        Order[] storage orders = orderBook[symbol][uint(side)];
        Order(counter, msg.sender, side, symbol, amount, price);
        counter++;
        //algoritmo para ordenarlos
        uint i = orders.length > 0? orders.length-1 : 0;
         if(side == Side.BUY){
           while(i>0){
               if(orders[i-1].price>orders[i].price){
                   break;
               }
               Order memory orderToMove = orders[i-1];
               orders[i - 1] = orders[i];
               orders[i] = orderToMove;
               i--;
           }
            
        }
        else if(side == Side.SELL){
            while(i>0){
               if(orders[i-1].price<orders[i].price){
                   break;
               }
               Order memory orderToMove = orders[i-1];
               orders[i - 1] = orders[i];
               orders[i] = orderToMove;
               i--;
           }
            
        }
        

       
    }


    function createMarketOrder(Side side, string memory symbol, uint amount) public{

        uint orderBookSide;
        if(side == Side.BUY){
           
            orderBookSide=1;
          
        }
        else{
            
           
            orderBookSide=0;
        }
        Order[] storage orders = orderBook[symbol][orderBookSide];
        uint totalFilled ;

        for(uint256 i=0; i<orders.length && totalFilled<amount ; i++){
           if(orders[i].amount<amount-totalFilled){
               totalFilled+=orders[i].amount;
               orders[i].filled+=orders[i].amount;
               if(orderBookSide==0){
                   require(balances[msg.sender][symbol]>=amount);
                   tokenBalances[msg.sender][symbol]-=orders[i].amount;
                   tokenBalances[orders[i].trader][symbol]+=orders[i].amount;
                   ethbalances[msg.sender]+=orders[i].amount*price;
                   ethbalances[orders[i].trader]-=orders[i].amount*price;
               }
               else{
                   require(ethbalances[msg.sender]>=amount*price);
                   tokenBalances[msg.sender][symbol]+=orders[i].amount;
                   tokenBalances[orders[i].trader][symbol]-=orders[i].amount;
                   ethbalances[msg.sender]-=orders[i].amount*price;
                   ethbalances[orders[i].trader]+=orders[i].amount*price;
               }
           }
           else {
               totalFilled+=amount-totalFilled;
               orders[i].filled+=amount-totalFilled;

               if(orderBookSide==0){
                   require(balances[msg.sender][symbol]>=amount);
                   tokenBalances[msg.sender][symbol]-=amount-totalFilled;
                   tokenBalances[orders[i].trader][symbol]+=amount-totalFilled;
                   ethbalances[msg.sender]+=(amount-totalFilled)*price;
                   ethbalances[orders[i].trader]-=(amount-totalFilled)*price;

               }
               else{
                   require(ethbalances[msg.sender]>=amount*price);
                   tokenBalances[msg.sender][symbol]+=amount-totalFilled;
                   tokenBalances[orders[i].trader][symbol]-=amount-totalFilled;
                   ethbalances[msg.sender]-=(amount-totalFilled)*price;
                   ethbalances[orders[i].trader]+=(amount-totalFilled)*price;


               }

           }

        }
         while(orders.length > 0 && orders[0].filled == orders[0].amount){
       
            for (uint256 i = 0; i < orders.length - 1; i++) {
                orders[i] = orders[i + 1];
            }
            orders.pop();
        }

    }
    
    
}