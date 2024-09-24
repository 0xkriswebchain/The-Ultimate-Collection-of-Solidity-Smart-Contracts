// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract SmartWallet {
    address private owner; // Gavin's address
    mapping(address => bool) private accessGranted; // Mapping to store addresses with access
    uint256 private balance; // Wallet balance
    uint256 private constant MAX_BALANCE = 10000; // Maximum wallet balance

    // Constructor to set the owner and initial balance
    constructor() {
        owner = msg.sender;
        balance = 0;
    }

    // Modifier to restrict access to only Gavin (contract owner)
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can execute this function");
        _;
    }

    // Modifier to restrict access to only Gavin and addresses with access
    modifier hasAccess() {
        require(msg.sender == owner || accessGranted[msg.sender], "Access denied");
        _;
    }

    // Function to add funds to the wallet's balance
    function addFunds(uint256 amount) public hasAccess {
        require(amount + balance <= MAX_BALANCE, "Balance cannot exceed 10000");
        balance += amount;
    }

    // Function to spend funds from the wallet's balance
    function spendFunds(uint256 amount) public hasAccess {
        require(amount <= balance, "Insufficient balance");
        balance -= amount;
    }

    // Function to grant access to an address
    function addAccess(address x) public onlyOwner {
        accessGranted[x] = true;
    }

    // Function to revoke access from an address
    function revokeAccess(address y) public onlyOwner {
        accessGranted[y] = false;
    }

    // Function to view the current balance of the wallet
    function viewBalance() public view hasAccess returns (uint256) {
        return balance;
    }
}
