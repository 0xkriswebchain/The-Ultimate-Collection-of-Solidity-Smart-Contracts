// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TeamWallet {
    address public deployer;
    address[] public members;
    uint256 public totalCredits;
    bool public walletSet;

    struct Transaction {
        uint256 amount;
        uint256 approvals;
        uint256 rejections;
        bool executed;
        bool failed;
    }

    Transaction[] public transactions;
    mapping(address => bool) public isMember;
    mapping(uint256 => mapping(address => bool)) public approvals;
    mapping(uint256 => mapping(address => bool)) public rejections;

    modifier onlyDeployer() {
        require(msg.sender == deployer, "Only deployer can call this function");
        _;
    }

    modifier onlyMember() {
        require(isMember[msg.sender], "Only team members can call this function");
        _;
    }

    modifier walletNotSet() {
        require(!walletSet, "Wallet already set");
        _;
    }

    constructor() {
        deployer = msg.sender;
    }

    function setWallet(address[] memory _members, uint256 _credits) public onlyDeployer walletNotSet {
        require(_members.length > 0, "Members required");
        require(_credits > 0, "Credits must be greater than 0");

        for (uint256 i = 0; i < _members.length; i++) {
            require(_members[i] != deployer, "Deployer cannot be a member");
            isMember[_members[i]] = true;
        }

        members = _members;
        totalCredits = _credits;
        walletSet = true;
    }

    function spend(uint256 amount) public onlyMember {
        require(amount > 0, "Amount must be greater than 0");

        Transaction memory newTransaction =
            Transaction({amount: amount, approvals: 1, rejections: 0, executed: false, failed: false});

        transactions.push(newTransaction);
        approvals[transactions.length - 1][msg.sender] = true;
    }

    function approve(uint256 n) public onlyMember {
        require(n < transactions.length, "Invalid transaction");
        require(!approvals[n][msg.sender] && !rejections[n][msg.sender], "Already voted");

        approvals[n][msg.sender] = true;
        transactions[n].approvals++;

        if (transactions[n].approvals * 10 >= members.length * 7) {
            if (transactions[n].amount <= totalCredits) {
                totalCredits -= transactions[n].amount;
                transactions[n].executed = true;
            } else {
                transactions[n].failed = true;
            }
        }
    }

    function reject(uint256 n) public onlyMember {
        require(n < transactions.length, "Invalid transaction");
        require(!approvals[n][msg.sender] && !rejections[n][msg.sender], "Already voted");

        rejections[n][msg.sender] = true;
        transactions[n].rejections++;

        if (transactions[n].rejections * 10 > members.length * 3) {
            transactions[n].failed = true;
        }
    }

    function credits() public view onlyMember returns (uint256) {
        return totalCredits;
    }

    function viewTransaction(uint256 n) public view onlyMember returns (uint256 amount, string memory status) {
        require(n < transactions.length, "Invalid transaction");

        Transaction memory txn = transactions[n];
        amount = txn.amount;

        if (txn.executed) {
            status = "debited";
        } else if (txn.failed) {
            status = "failed";
        } else {
            status = "pending";
        }
    }
}
