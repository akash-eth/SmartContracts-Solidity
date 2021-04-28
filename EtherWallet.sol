// SPDX-License-Identifier: Unidentified
pragma solidity ^0.5.0;

contract EtherWallet {
    
    address public owner;
    
    constructor(address _owner) public {
        owner = _owner;
    }
    
    function deposit() payable public {
        
    }
    
    function send(address payable _to, uint _amount) public {
        if (msg.sender == owner) {
            _to.transfer(_amount);
            return;
        }
        revert ('Unauthorized user');
    }
    
    function balanceOf() view public returns(uint){
        return address(this).balance;
    }
    
}