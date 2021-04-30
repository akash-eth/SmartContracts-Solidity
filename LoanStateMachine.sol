pragma solidity ^0.5.0;


contract StateMachine {
    
    enum State {
        PENDING,
        ACTIVE,
        CLOSED
    }
    
    State public state = State.PENDING;
    uint public amount;
    uint public interest;
    uint duration;
    
    address payable public lender;
    address payable public borrower;
    
    constructor(
        uint _amount,
        uint _interest,
        uint endTime,
        address payable _lender,
        address payable _borrower
        )
        public
        {
            amount = _amount;
            interest = _interest;
            endTime = now + duration;
            lender = _lender;
            borrower = _borrower;
        }
        
    function fund(uint _amount) payable public {
        require(msg.sender == lender, 'Only lender can fund !!');
        require(address(this).balance == amount, 'can not fund more than the amount');
        _transitionTo(State.ACTIVE);
        borrower.transfer(amount);
    }
    
    function reimburse() payable external {
        require(msg.sender == borrower, 'Only borrower can reimburse');
        require(msg.value == amount+interest, 'Interest must be added to the amount')
        _transitionTo(State.CLOSED);
        lender.transfer(amount);
    }
    
    function _transitionTo(State _to) internal {
        require(_to != State.PENDING, 'can not go back to pending state');
        require(_to != state, 'cannot transition to surrent state itself');
        if(_to == State.ACTIVE) {
            require(State != state.PENDING, 'canot go to pending from an active state');
            state = State.ACTIVE;
        }
        if(_to == State.CLOSED) {
            require(state != State.PENDING, 'can not go back to pending state');
            require(now >= duration, 'can not transit to closed state before duration');
            state = State.CLOSED;
        }
    }
}


