// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.5.0;

contract Deed {
    
    address public lawyer;
    address payable public beneficiary;
    // uint amount;
    uint transferTime;
    
    constructor(
        address _lawyer,
        address payable _beneficiary,
        // uint _amount,
        uint fromNow
        )
        payable public {
            lawyer = _lawyer;
            beneficiary = _beneficiary;
            // amount = _amount;
            transferTime = block.timestamp + fromNow;
        }
    
    function withdraw() payable public {
        require(msg.sender == lawyer, 'only lawyer can transfer funds');
        require(block.timestamp >= transferTime, 'too early to withdraw');
        
        beneficiary.transfer(address(this).balance);
    }
    
}