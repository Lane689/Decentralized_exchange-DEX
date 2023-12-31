// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "..//node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "..//node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract Wallet is Ownable{

    using SafeMath for uint256; 

    struct Token{
        bytes32 ticker;
        address tokenAddress;
    }

    modifier tokenExist(bytes32 ticker){
        require(tokenMapping[ticker].tokenAddress != address(0), "Token does not exist"); 
        _;
    }

    mapping(bytes32 => Token) public tokenMapping;
    bytes32[] public tokenList;

    mapping(address => mapping(bytes32 => uint256)) public balances; 
                                                                   
    function addToken(bytes32 ticker, address tokenAddress) onlyOwner external {
        tokenMapping[ticker] = Token(ticker, tokenAddress);
        tokenList.push(ticker);
    }

    function deposit(uint amount, bytes32 ticker) external tokenExist(ticker) {
        IERC20(tokenMapping[ticker].tokenAddress).transferFrom(msg.sender, address(this), amount);
        balances[msg.sender][ticker] = balances[msg.sender][ticker].add(amount);
    }

    function withdraw(uint amount, bytes32 ticker) external tokenExist(ticker) {
        require(balances[msg.sender][ticker] >= amount, "Balance not sufficient");
        
        balances[msg.sender][ticker] = balances[msg.sender][ticker].sub(amount);
        IERC20(tokenMapping[ticker].tokenAddress).transfer(msg.sender, amount); 
    }


    
}