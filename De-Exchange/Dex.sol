// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol';
import 'https://github.com/ConsenSysMesh/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol';

contract Dex {
    
    using SafeMath for uint;
    
    enum Side {
        BUY,
        SELL
    }
    
    struct Order {
        uint id;
        address trader;
        Side side;
        uint amount;
        uint filled;
        uint price;
        uint date;
    }
    
    struct Token {
        bytes32 ticker;
        address tokenAddress;
    }   
    
    mapping(bytes32 => Token) public tokens;
    mapping(address => mapping(bytes32 => uint)) public traderBalances;
    mapping(bytes32 => mapping(uint => Order[])) public orderBook;  // ENUM can be taken as an integer value (0 and 1); so, here in our 2nd mapping uint represents ENUM;
    
    event NewTrade(
        uint tradeId,
        uint orderId,
        bytes32 indexed ticker,
        address indexed trader1,
        address indexed trader2,
        uint amount,
        uint price,
        uint date
        );
    
    bytes32[] public tokenList;
    bytes32 constant DAI = bytes32('DAI');
    
    uint nextOrderId;
    uint nextTradeId;
    
    address admin;
    
    constructor() {
        admin == msg.sender;
    }
    
    function addToken(bytes32 _ticker, address _tokenAddress) external onlyAdmin() {
        tokens[_ticker] = Token(_ticker, _tokenAddress);
        tokenList.push(_ticker);
    }
    
    function deposit(bytes32 _ticker, uint _amount) external tokenExist(_ticker) {
        IERC20(tokens[_ticker].tokenAddress).transferFrom(
                msg.sender, // transfer from
                address(this),  // transfer to
                _amount
            );
        traderBalances[msg.sender][_ticker] = traderBalances[msg.sender][_ticker].add(_amount);
    }
    
    function withdraw(bytes32 _ticker, uint _amount) external tokenExist(_ticker) {
        require(traderBalances[msg.sender][_ticker] >= _amount, 'token does not exist');
        IERC20(tokens[_ticker].tokenAddress).transfer(
                msg.sender,
                _amount
            );
        traderBalances[msg.sender][_ticker] = traderBalances[msg.sender][_ticker].sub(_amount);
    }
    
    function placeOrder(
            bytes32 _ticker,
            uint _amount,
            uint _price,
            Side side
        ) external tokenExist(_ticker) tokenIsNotDAI(_ticker) {
            if(side == Side.SELL) {
                require(traderBalances[msg.sender][_ticker] >= _amount, 'balance too low');
            } else {
                require(traderBalances[msg.sender][DAI] >= _amount.mul(_price));
            }
            Order[] storage orders = orderBook[_ticker][uint(side)];
            orders.push(Order(
                    nextOrderId,
                    msg.sender,
                    side,
                    _amount,
                    0,      // filled is initially set to 0
                    _price,
                    block.timestamp
                ));
         
         uint i = orders.length > 0 ? orders.length - 1 : 0;
         while(i > 0) {
             if(side == Side.BUY && orders[i - 1].price > orders[i].price) {
                 return;
             }
             if(side == Side.SELL && orders[i - 1].price > orders[i].price) {
                 return;
             }
             Order memory order = orders[i - 1];
             orders[i - 1] = orders[i];
             orders[i] = order;
             i = i.sub(1);
             nextOrderId = nextOrderId.add(1);
         }
            
        }
        
    function createMarketOrder(
            bytes32 _ticker,
            uint _amount,
            Side side
        ) external tokenExist(_ticker) {
            if(side == Side.SELL) {
                require(traderBalances[msg.sender][_ticker] >= _amount, 'token balance too low');
            }
            Order[] storage orders = orderBook[_ticker][uint(side == Side.BUY ? Side.SELL : Side.BUY)];
            uint i; // variable to iterate through orderBook
            uint remaining = _amount;   // how many orders are remaining in an orderBook
            uint available = orders[i].amount.sub(orders[i].filled);
            uint matched = (remaining > available) ? available : remaining;
            remaining = remaining.sub();
            orders[i].filled = orders[i].filled.add(matched);
            
            emit NewTrade(
                nextTradeId,
                orders[i].id,
                _ticker,
                orders[i].trader,
                msg.sender,
                matched,
                orders[i].price,
                block.timestamp
                );
                
            if(side == Side.SELL) {
                traderBalances[msg.sender][_ticker] = traderBalances[msg.sender][_ticker].sub(matched);
                traderBalances[msg.sender][DAI] = traderBalances[msg.sender][DAI].add(matched.mul(orders[i].price));
                traderBalances[orders[i].trader][_ticker] = traderBalances[orders[i].trader][_ticker].add(matched);
                traderBalances[orders[i].trader][DAI] = traderBalances[orders[i].trader][DAI].sub(matched.mul(orders[i].price));
            }
            
            if(side == Side.BUY) {
                require(traderBalances[msg.sender][DAI] >= matched.mul(orders[i].price), 'Not enough DAI to complete thr transaction');
                traderBalances[msg.sender][_ticker] = traderBalances[msg.sender][_ticker].add(matched);
                traderBalances[msg.sender][DAI] = traderBalances[msg.sender][DAI].sub(matched * orders[i].price);
                traderBalances[orders[i].trader][_ticker] = traderBalances[orders[i].trader][_ticker].sub(matched);
                traderBalances[orders[i].trader][DAI] = traderBalances[orders[i].trader][DAI].add(matched.mul(orders[i].price));
            }
            
            nextTradeId = nextTradeId.add(1);
            i = i.add(1);
            
            i = 0;
        
            while(i < orders.length && orders[i].filled == orders[i].amount) {
                for(uint j = i; j < orders.length -1; j = j++) {
                    orders[j] = orders[j+1];
                }
                orders.pop();
                i = i.add(1);
            }
        }
        
        
        
        
        
    modifier tokenIsNotDAI(bytes32 _ticker) {
        require(tokens[_ticker].ticker != DAI, 'can not trade DAI');
        _;
    }
    
    modifier tokenExist(bytes32 _ticker) {
        require(tokens[_ticker].tokenAddress != address(0));
        _;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }
 
}