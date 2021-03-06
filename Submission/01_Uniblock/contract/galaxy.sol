pragma solidity >=0.5.1 <0.7.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
}
contract Galaxy {
    using SafeMath
    for uint256;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowed;
    uint256 private _totalSupply;
    
    //for Uniblock
    uint256 _deposit;
    address payable _owner;
    address _forCheck;
    
    bool isItSuccess = false;
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    constructor(string memory name, string memory symbol, address payable owner, address forCheck) payable public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
        _owner = owner;
        _forCheck = forCheck;
    }
    
    function setDeposit() payable public {
        require(
            msg.sender == _forCheck,
            "permit denind"
        );
        _deposit = msg.value;
    }
    
    function getDeposit() payable public {
        if(isItSuccess)
        _owner.transfer(_deposit);
    }
    
    function test_finish() public {
        isItSuccess = true;
    }
    
    function test_noneFinish() public {
        isItSuccess = false;
    }
    /////////////////////////

    function name() public view returns(string memory) {
        return _name;
    }

    function symbol() public view returns(string memory) {
        return _symbol;
    }

    function decimals() public view returns(uint8) {
        return _decimals;
    }

    function totalSupply() public view returns(uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view returns(uint256) {
        return _balances[owner];
    }

    function allowance(address owner, address spender) public view returns(uint256) {
        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns(bool) {
        if(!isItSuccess) return false;
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns(bool) {
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns(bool) {
        if(!isItSuccess) return false;
        require(value <= _allowed[from][msg.sender]);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }
    
    function buyToken() payable public returns(bool){
        _owner.transfer(msg.value);
        uint256 ETH = (10 ** 18);
        uint256 zeroDotOne = ETH / 10;
        _mint(msg.sender, msg.value/zeroDotOne);
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(value <= _balances[from]);
        require(to != address(0));
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        require(account != address(0));
        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0));
        require(value <= _balances[account]);
        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _burnFrom(address account, uint256 value) internal {
        require(value <= _allowed[account][msg.sender]);
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
    }
}