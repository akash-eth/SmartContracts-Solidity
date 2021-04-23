//SPDX-License-Identifier: Undefined

pragma solidity >= 0.5.0;

contract AdvanceStorage {
    
    uint[] public ids;
    
    function setIDS(uint _id) public {
        ids.push(_id);
    }
    
    function getIDS(uint _position) view public returns(uint) {
        return ids[_position];
    }
    
    function getAllIDS() view public returns(uint[] memory) {
        return ids;
    }
    
    function getLength() view public returns(uint) {
        return ids.length;
    }
    
}