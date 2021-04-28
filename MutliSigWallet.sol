// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.5.0;


contract MultiSigWallet {
    
    address[] public approvers;
    uint public quorum; // minimum numbers of approvals required !!
    
    struct Transfer {
        uint id;
        uint amount;
        address payable to;
        uint approvals;
        bool sent;
    }
    
    mapping(uint => Transfer) transfers;
    mapping(address => mapping(uint => bool)) approvals;
    
    uint nextId;
    
    constructor(address[] memory _approvers, uint _quorum)
        payable
        public
        {
            approvers = _approvers;
            quorum = _quorum;
        }
        
    function createTramsfer(uint _amount, address payable _to) external onlyApprover() {
        transfers[nextId] = Transfer(
                nextId,
                _amount,
                _to,
                0,
                false
            );
            nextId++;
        
    }
    
    function sentTransfer(uint _id) external onlyApprover() {
        
        require( transfers[_id].sent == false, "transfer alreadt send");
        
        if(transfers[_id].approvals >= quorum ) {
            transfers[_id].sent = true;
            address payable to = transfers[_id].to;
            uint amount = transfers[_id].amount;
            
            to.transfer(amount);
            return;
        }
        /*
            we want to cehck that the msg.semder (who is sending the send transfer function)
            has not already approved this transfer function. Because without this it can access the 
            sentTransfer function infinite time and match the quorum.
            
            i.e. each approval has to be unique:
            
        */
        if(approvals[msg.sender][_id] == false) {
            approvals[msg.sender][_id] == true;
            transfers[_id].approvals++;
        }
        
        
    }
    
    modifier onlyApprover() {
        bool allowed = false;
        for(uint i=0; i < approvers.length; i++) {
            if(approvers[i] == msg.sender) {
                allowed = true;
            }
        }
        require(allowed == true, "only approvers allowed");
        _;
    }
    
}