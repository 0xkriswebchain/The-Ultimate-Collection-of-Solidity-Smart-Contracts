// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimplePaymentChannel {
    address public owner;
    address public recipient;
    address public depositor;
    uint256 public balance;
    uint256[] public payments;

    constructor(address recipientAddress) {
        owner = msg.sender;
        recipient = recipientAddress;
    }

    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        depositor = msg.sender;
        balance += msg.value;
    }

    function listPayment(uint256 amount) public {
        require(msg.sender == depositor, "Only the depositor can list payments");
        require(amount <= balance, "Insufficient balance to list payment");
        payments.push(amount);
        balance -= amount;
    }

    function closeChannel() public {
        require(msg.sender == owner || msg.sender == recipient, "Only owner or recipient can close the channel");
        uint256 remainingBalance = balance;
        balance = 0;
        payable(depositor).transfer(remainingBalance);
    }

    function checkBalance() public view returns (uint256) {
        return balance;
    }

    function getAllPayments() public view returns (uint256[] memory) {
        return payments;
    }
}