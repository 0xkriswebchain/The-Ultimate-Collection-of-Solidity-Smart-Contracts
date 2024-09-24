// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ScholarshipCreditSystem {
    address public owner;
    uint256 public totalCredits = 1000000;
    mapping(address => uint256) public balances;
    mapping(address => bool) public registeredMerchants;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier onlyStudent() {
        require(balances[msg.sender] > 0, "Only students with scholarships can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
        balances[owner] = totalCredits;
    }

    function grantScholarship(address studentAddress, uint256 credits) public onlyOwner {
        require(studentAddress != address(0), "Invalid student address");
        require(studentAddress != owner, "Owner cannot grant scholarship to themselves");
        require(credits > 0, "Credits must be greater than zero");
        require(balances[owner] >= credits, "Not enough credits available");
        balances[owner] -= credits;
        balances[studentAddress] += credits;
        totalCredits -= credits; // Update total credits
    }

    function registerMerchantAddress(address merchantAddress) public onlyOwner {
        require(merchantAddress != address(0), "Invalid merchant address");
        require(!registeredMerchants[merchantAddress], "Merchant is already registered");
        registeredMerchants[merchantAddress] = true;
    }

    function deregisterMerchantAddress(address merchantAddress) public onlyOwner {
        require(merchantAddress != address(0), "Invalid merchant address");
        require(registeredMerchants[merchantAddress], "Merchant is not registered");
        registeredMerchants[merchantAddress] = false;
    }

    function revokeScholarship(address studentAddress) public onlyOwner {
        require(studentAddress != address(0), "Invalid student address");
        require(balances[studentAddress] > 0, "Student has no scholarship to revoke");
        uint256 studentBalance = balances[studentAddress];
        balances[studentAddress] = 0;
        balances[owner] += studentBalance;
        totalCredits += studentBalance; // Update total credits
    }

    function spend(address merchantAddress, uint256 amount) public onlyStudent {
        require(merchantAddress != address(0), "Invalid merchant address");
        require(registeredMerchants[merchantAddress], "Merchant is not registered");
        require(amount > 0, "Amount must be greater than zero");
        require(balances[msg.sender] >= amount, "Not enough credits");
        balances[msg.sender] -= amount;
        balances[merchantAddress] += amount;
    }

    function checkBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}
