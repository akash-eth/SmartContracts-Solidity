//SPDXLicense-Identifier:MIT
pragma solidity ^0.8.0;


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
    uint public _totalSupply;
    
    mapping(address => uint) public balances;
    mapping(address => mapping(address =>uint)) public allowed;     // 1st address is for the tokenOwner, 2nd address is for the spender !!
    
    constructor(
            string memory _name,
            string memory _symbol,
            uint _decimals,
            uint _totalSupply
        )  
        {
            name = _name;
            symbol = _symbol;
            decimals = _decimals;
            _totalSupply = _totalSupply;
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

