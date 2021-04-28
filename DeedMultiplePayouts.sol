// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.5.0;


contract DeedMultiPayouts {
    
    address public lawyer;
    address payable public beneficiary;
    uint transferTime;
    uint constant public PAYOUTS = 10;
    uint constant public INTERVAL = 10; // In seconds
    uint public paidPayouts;
    uint public amount;
    
    constructor(
        address _lawyer,
        address payable _beneficiary,
        uint fromNow
        )
        public
        payable
        {
            lawyer = _lawyer;
            beneficiary = _beneficiary;
            transferTime = block.timestamp + fromNow;
            amount = msg.value / PAYOUTS;
        }
    
    
    function withdrawDeed() payable public{
        require(msg.sender == beneficiary, 'only beneficiary can send funds');
        require(block.timestamp >= transferTime, 'too early');
        
        require(paidPayouts < PAYOUTS, 'no payouts left');
        
        uint eligiblePayouts = (block.timestamp - transferTime) / INTERVAL;
        uint duePayouts = eligiblePayouts - paidPayouts;
        
        
        /*
            @dev: Ternary operator on duePayouts to prevent contract from getting locked forever:
                    
                    condition: if(duePayouts + paidPayouts) greater than PAYOUTS(total amount to be paid) {
                        then set it equal to PAYOUTS by default
                    } else {
                      let it be duePayouts  
                    }
        */
        duePayouts = (duePayouts + paidPayouts) > PAYOUTS ? PAYOUTS - paidPayouts : duePayouts; 
        paidPayouts += duePayouts;
        beneficiary.transfer(eligiblePayouts * amount);
    }
    
}