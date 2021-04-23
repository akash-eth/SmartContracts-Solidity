
// SPDX-License-Identifier: UNLICENSED

pragma solidity >= 0.5.0;

contract SimpleStorage {
    
    string public data;
    
    function storeData(string memory _data) public {
        data = _data;
    }
    
    function getData() view public returns(string memory) {
        return data;
    }
}