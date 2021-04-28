// SPDX-License-Identifier: UNLICENSED

pragma solidity >= 0.5.0;
pragma experimental ABIEncoderV2;

contract Voting {
    
    mapping(address => bool) public voters;
    
    struct Choice {
        uint id;
        string name;
        uint votes;
    }
    
    struct Ballot {
        uint id;
        string name;
        Choice[] choices;
        uint endTime;
    }
    
    mapping(uint => Ballot) ballots;
    
    uint public nextBallotId;
    
    address public admin;
    
    mapping(address => mapping(uint => bool)) votes;
    
    constructor() public {
        admin = msg.sender;
    }
    
    function addVoter(address[] calldata _voters) external onlyAdmin() {
        
        for(uint i=0; i < _voters.length; i++) {
            voters[_voters[i]] = true;
        }
    }
    
    function createBallot(
        string memory _name,
        string[] memory _choices,
        uint _offset
        ) 
        public onlyAdmin()  
        {
            
            ballots[nextBallotId].id = nextBallotId;
            ballots[nextBallotId].name = _name;
            ballots[nextBallotId].endTime = block.timestamp + _offset;
            for(uint i=0; i < _choices.length; i++) {
                ballots[nextBallotId].choices.push(Choice(i, _choices[i], 0));
            }
            
        }
        
    function vote(uint _ballotId, uint _choiceId) external {
        
        require(voters[msg.sender] == true, 'only voter can vote');
        require(votes[msg.sender][_ballotId] == false, 'voter can only vote once');
        require(block.timestamp < ballots[_ballotId].endTime, 'can only vote within ballot end time');
        
        votes[msg.sender][_ballotId] = true;
        ballots[_ballotId].choices[_choiceId].votes++;
    }
    
    function results(uint _ballotId) view public returns(Choice[] memory) {
        require(block.timestamp >= ballots[_ballotId].endTime, 'can not see the results before voting ends');
        return ballots[_ballotId].choices;
    }
        
    modifier onlyAdmin() {
        require(msg.sender == admin, 'only Admin');
        _;
    }
}