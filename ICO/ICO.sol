//SPDX-License-Identifier:MIT

pragma solidity >= 0.5.6;


interface IERC20 {
    
    function transfer(address to, uint tokens) external returns(bool success);
    function transferFrom(address from, address to, uint tokens) external returns(bool success);
    function approve(address spender, uint tokens) external returns(bool success);
    function balanceOf(address tokenOwner) external returns(uint);
    function allowance(address tokenOwner, address spender) external view returns(uint remaining);
    function totalSupply() external view returns(uint);
    
    event Transfer(address indexed from, address indexed to, uint amount);
    event Approve(address indexed tokenOwner, uint tokens);
}

contract ERC20Token is IERC20 {
    
    string public name;
    string public symbol;
    uint public decimals;
    uint public totalSupply;
    
    mapping(address => uint) public balances;
    mapping(address => mapping(address =>uint)) public allowed;     // 1st address is for the tokenOwner, 2nd address is for the spender !!
    
    constructor(
            string memory _name,
            string memory _symbol,
            uint _decimals,
            uint _totalSupply
        ) public 
        {
            name = _name;
            symbol = _symbol;
            decimals = _decimals;
            totalSupply = _totalSupply;
            balances[msg.sender] = _totalSupply;
        }
        
    function transfer(address _to, uint _amount) external returns(bool) {
        require(balances[msg.sender] >= _amount, 'Not enough funds left !!');
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint _amount) external returns(bool) {
        uint allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _amount && allowance >= _amount, 'Not enough to allow others to transact on your behalf');
        allowed[_from][msg.sender] -= _amount;
        balances[_from] -= _amount;
        balances[_to] += _amount;
    }
    
    function approve(address _spender, uint _amount) external returns(bool) {
        require(msg.sender != _spender);
        allowed[msg.sender][_spender] = _amount;
        //balances[msg.sender] -= _amount;
        emit Approve(_spender, _amount);
        return true; 
    }
    
    function allowance(address _tokenOwner, address _spender) public view returns(uint) {
        return allowed[_tokenOwner][_spender];
    }
    
    function balanceOf(address _tokenOwner) public returns(uint) {
        return balances[_tokenOwner];
    }
    
}


contract ICO {
    
    // This struct will be used to store:
    // How many tokens are assigned to an investor address !!
    // And have called it in BUY function.
    struct Sale {
        address investor;
        uint quantity;
    }
    
    Sale[] public sales;
    
    mapping(address => bool) public investors;
    
    address tokenAddress;
    address admin;
    uint public endTime;
    uint public price;
    uint public availableTokens;
    uint public minPurchase;
    uint public maxPurchase;
    bool public released;
    
    constructor(
        string memory _name,
        string memory _symbol,
        uint _decimals,
        uint _totalSupply
        )
        public 
        {
        tokenAddress = address(new ERC20Token(
                _name,
                _symbol,
                _decimals,
                _totalSupply
                ));
                
        admin = msg.sender;
        }
    
    
    function start(
        uint _duration,
        uint _price,
        uint _availableTokens,
        uint _minPurchase,
        uint _maxPurchase
        ) 
        external 
        onlyAdmin()
        icoNotActive()
        {
        
        uint totalSupply = ERC20Token(tokenAddress).totalSupply();
        
        require(_duration > 0, 'duration should be');
        require(_availableTokens >= 0 && _availableTokens <= totalSupply);
        require(minPurchase > 0, 'minPurchase should be > 0');
        require(maxPurchase > 0 && maxPurchase <= _availableTokens);
        
        endTime = _duration + now;
        price = _price;
        availableTokens = _availableTokens;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
    }
    
    function whitelist(address _investor) external onlyAdmin() {
        investors[_investor] = true;
    }
    
    /*
        We will not send the token in the BUY function.
        As this is elimate the ICO fundamentals.
        We will send token after the endTime of ICO is over.
        Using a different function !!
        Here will assign the token to the whitelisted address.
    */
    
    function buy() payable external onlyInvestor() icoActive() {
        require(msg.value % price == 0, 'can only invest in multiple of price');
        require(msg.value >= minPurchase && msg.value <= maxPurchase, 'out of limit');
        uint quantity = msg.value * price;
        require(quantity <= availableTokens, 'not enough tokens left');
        
        // calling sales array to store investor address and tokens assigned to him !!
        sales.push(Sale(
            msg.sender,
            quantity
            ));
    } 
    
    function release() external onlyAdmin() icoEnded() tokensNotReleased() {
        ERC20Token tokenInstance = ERC20Token(tokenAddress);
        for (uint i = 0; i < sales.length; i++) {
            Sale storage sale = sales[i];
            tokenInstance.transfer(sale.investor, sale.quantity);
        }
    }
    
    function withdraw(
            address payable _to,
            uint _amount
        ) external onlyAdmin() icoEnded() tokensReleased() {
        _to.transfer(_amount);
    }
    
    modifier icoActive() {
        require(endTime > 0 && now < endTime && availableTokens > 0, "ico is not active");
        _;
    }
    
    modifier icoEnded() {
        require(endTime > 0 && (now > endTime || availableTokens == 0));
        _;
    }
    
    modifier icoNotActive() {
        require(endTime == 0, 'ICO should not be active');
        _;
    }
    
    modifier tokensNotReleased() {
        require(released == false, 'token must not released yet');
        _;
    }
    
    modifier tokensReleased() {
        require(released == true, 'token must have released');
        _;
    }
    
    modifier onlyInvestor() {
        require(investors[msg.sender] == true);
        _;
    }
    
    modifier onlyAdmin() {
        msg.sender == admin;
        _;
    }
}




