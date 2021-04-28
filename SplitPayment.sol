// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.5.0;

contract SplitPayment {
    
    address public owner;
    
    constructor(address _owner) payable public {
        owner = _owner;
    }
    
    function deposit() payable public {
        
    }
    
    function sendPayment(address payable[] memory _to, uint[] memory _amount) payable public onlyOwner() {
        
        require(_to.length == _amount.length, 'both arrays must be equal in lengths');
        
        for(uint i=0; i < _to.length; i++) {
            _to[i].transfer(_amount[i]);
        }
        
    }
    
    modifier onlyOwner() {
        require (msg.sender == owner, 'Only owner can send payments');
        _;
    }
    
}