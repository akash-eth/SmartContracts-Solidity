pragma solidity ^0.5.0;

// Investers will invest
contract DAO {
    
    // Adding a struct for a new proposal:
    struct Proposal {
        uint id;
        string name;
        uint amount;
        address payable recipient;
        uint vote;
        uint end;
        bool executed;
    }
    
    mapping(address => bool) public investors;
    mapping(address => uint) public shares;    // how many shares does one investor has in the DAO
    
    // Making a mapping of Proposal struct:
    mapping(uint => Proposal) public proposals;
    mapping(address => mapping(uint => bool)) public votes;
    
    
    /*
        To get the total shares available in the DAO contract:
        This will help us to find out how much share does one investor
        has in our DAO contarct by calculating:
            totalShares = share;
    */
    uint public totalShares;
    uint public availableFunds;
    uint public contributionEndTime;
    
    // declaring variables for proposal feature:
    uint public nextProposalId;
    uint public voteTime;
    uint public quorum;
    address public admin;
    
    constructor(
        uint contributionTime,
        uint _voteTime,
        uint _quorum
        ) 
        public 
        {
            require(_quorum > 0 && _quorum < 100, 'quorum must be in definite range');
            contributionEndTime = now + contributionTime;    // Investors can only invest till now + contributionTime;
            voteTime = _voteTime;
            quorum = _quorum;
            admin = msg.sender;
    }
    
    function contribute() payable external {
        
        require(now < contributionEndTime, 'Contribution window is closed');
        
        investors[msg.sender] = true;
        shares[msg.sender] = msg.value;
        totalShares += msg.value;
        availableFunds += msg.value;
    }
    
    /*
        If an investor wants to reedem his shares in return of ether
        after the contribution window is closed. Then:
        
        1. reedeemShares function: he can redeem directly from the total funds:
        
        2. transferShares function: he can transfer funds to another party
    */
    function reedemShares(uint _amount) external {
        require(shares[msg.sender] >= _amount, 'amount exceeds available shares');
        require(availableFunds >= _amount, 'amount exceeds totalShares');
        
        shares[msg.sender] -= _amount;
        availableFunds -= _amount;
        
        msg.sender.transfer(_amount);
    }
    
    /*
        This function will be used by an 3rd party exchange and will have no relation with this contract:
        As, they will hold the bid that party-A wants to sell shares !!
        Then, party-B will see that notification and send request to buy those shares !!
    */
    function transferShares(uint _amount, address _to) external {
        require(shares[msg.sender] >= _amount, 'amount exceeds available shares');
        require(availableFunds >= _amount, 'amount exceeds totalShares');
        shares[msg.sender] -= _amount;
        shares[_to] += _amount;
        investors[_to] = true;
        
    }
    
    
    function createProposal (
            string calldata _name,
            uint _amount,
            address payable _recipient
        ) external onlyInvestor() {
            require(availableFunds >= _amount, 'amount exceeds availableFunds');
            proposals[nextProposalId] = Proposal(
                    nextProposalId,
                    _name,
                    _amount,
                    _recipient,
                    0,
                    now + voteTime,
                    false
                );
            availableFunds -= _amount;
            nextProposalId++;
        }
        
    function vote(uint _proposalId) external onlyInvestor() {
        Proposal storage proposal = proposals[_proposalId];
        require(votes[msg.sender][_proposalId] == false, 'voter can only vote once');
        require(now > proposal.end);
        votes[msg.sender][_proposalId] = true;
        proposal.vote += shares[msg.sender];
    }
    
    function executeProposal(uint _proposalId) external onlyAdmin() {
        Proposal storage proposal = proposals[_proposalId];
        require(now >= proposal.end, 'can not release funds before funding window closes');
        require(proposal.executed == false, 'proposal already executed');
        require((proposal.vote / totalShares) * 100 >= quorum, 'not enough votes');
        _transferEther(proposal.amount, proposal.recipient);
    }
    
    /*
        withdraw function will be used in emergency !!
    */
    function withdrawFunds(uint _amount, address payable _to) external onlyAdmin() {
        _transferEther(_amount, _to);
    }
    
    // fallback function to receive the funds from the recipient contract into our DAO contract from an 3rd party!!
    function() payable external {
        availableFunds += msg.value;
    }
    
    function _transferEther(uint _amount, address payable _to) internal  {
        require(_amount <= availableFunds, 'not enough funds');
        availableFunds -= _amount;
        _to.transfer(_amount);
    }
    
    modifier onlyInvestor() {
        require(investors[msg.sender] == true, 'only investors can proceed');
        _;
    }
    
     modifier onlyAdmin() {
        require(msg.sender == admin, 'only admin can proceed');
        _;
    }
}