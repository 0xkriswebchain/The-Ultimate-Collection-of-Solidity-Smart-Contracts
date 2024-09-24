// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Implement the ERC-20 smart contract.
contract Token {

    address public owner;
    string public name;
    string public symbol;
    uint256 public totalSupply;
    mapping (address => uint256) public balances;
    mapping (address => bool) public blacklisted;
    mapping (address => mapping (address => uint256)) public allowances;

    constructor(string memory _name, string memory _symbol) {
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
        totalSupply = 0; // Initialize totalSupply to 0
    }

    function mint(address _to, uint256 _amount) public onlyOwner {
        balances[_to] += _amount;
        totalSupply += _amount; // Increment totalSupply
    }

    function burn(uint256 _amount) public onlyNotBlacklisted {
        require (balances[msg.sender] >= _amount, "Insufficient Balance");
        balances[msg.sender] -= _amount;
        totalSupply -= _amount; // Decrement totalSupply
    }

    function batchMint(address[] calldata _to, uint256[] calldata _amounts) public onlyOwner {
        require (_to.length == _amounts.length, "Arrays are not matching");
        require(_to.length > 0, "Array is empty");
        for (uint256 i = 0; i < _to.length; i++) {
            mint(_to[i], _amounts[i]);
        }
    }

    function publicMint(uint256 _amount) public payable {
    require (_amount > 0, "Amount cannot be zero");
    uint256 price = totalSupply * 0.001 ether; // Calculate price based on current totalSupply
    require(msg.value >= price * _amount, "Insufficient balance"); // Check if sent value is sufficient
    mint(msg.sender, _amount);
}

    function blacklistUser(address _user) public onlyOwner {
    require(!blacklisted[_user], "User is already blacklisted");
    burn(balances[_user]); // Burn the tokens held by the user
    blacklisted[_user] = true;
}

    function transfer(address _to, uint256 _amount) public onlyNotBlacklisted returns (bool) {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) public onlyNotBlacklisted returns (bool) {
        require(balances[_from] >= _amount, "Insufficient balance");
        require(allowances[_from][msg.sender] >= _amount, "Insufficient allowance");
        balances[_from] -= _amount;
        balances[_to] += _amount;
        allowances[_from][msg.sender] -= _amount;
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function approve(address _spender, uint256 _amount) public onlyNotBlacklisted returns (bool) {
        allowances[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowances[_owner][_spender];
    }

    function Name() public view returns (string memory) {
        return name;
    }

    function Symbol() public view returns (string memory) {
        return symbol;
    }

    function balanceOf(address _user) public view returns (uint256) {
        return balances[_user];
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(address indexed _owner, address indexed _spender, uint256 _amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier onlyNotBlacklisted() {
        require(!blacklisted[msg.sender], "Blacklisted user cannot call this function");
        _;
    }
}