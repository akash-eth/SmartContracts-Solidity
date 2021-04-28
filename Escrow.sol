// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.5.0;


// Escrow: Party-A buys assets from party-B with and 3rd party medium i.e. lawyer...
contract Escrow {
    
    address public payer;
    address payable public payee;
    address public lawyer;
    uint public amount;
    
    constructor(address _payer, address payable _payee, uint _amount) public {
        payer = _payer;
        payee = _payee;
        lawyer = msg.sender;
        amount = _amount;
    }
    
    function deposit() payable public {
        require(msg.sender == payer, "only payer can deposit funds to contract");
        require(address(this).balance <= amount, "contarct balance should be less than or equal to predeined amount");
    }
    
    function releaseFunds() public {
        require(address(this).balance == amount, "balance should be equal to predefined Amount");
        require(msg.sender == lawyer, "only lawyer can release funds");
        payee.transfer(address(this).balance);
    }
    
    function balanceOf() public view returns(uint) {
        return address(this).balance;
    }
}