// SPDX-License-Identifier: MIT
pragma solidity >0.6.0 <0.9.0;

contract Helloworld {
    string MESSAGE = "HelloWorld"; 

    function setMessage(string memory message) public payable{
        MESSAGE = message;
    }
    
    function hello() public view returns (string memory){
        return MESSAGE;
    }
}

