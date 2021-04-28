// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.5.0;


contract Fibonacci {
    
    function generateFibonacci(uint _range) public pure returns(uint) {
        
        uint num1 = 0;
        uint num2 = 1;
        uint num3;
        
        for(uint i=0; i < _range; i++) {
            num3 = num1 + num2;
            num1 = num2;
            num2 = num3;
        }
        
        return(num3);
        
    }
    
}