// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract IsContract {
    
    function isContract(address contractAddress) view public returns(bool) {
        uint codeLength;
        assembly {
            // this gives us the code size of an existing address !!
            codeLength := extcodesize(contractAddress)
        }
        return codeLength == 0 ? false : true;
    }
    
}