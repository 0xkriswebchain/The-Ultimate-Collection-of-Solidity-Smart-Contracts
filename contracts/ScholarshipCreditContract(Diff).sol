// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract ScholarshipCreditContract {
    address public owner;
    uint256 public totalCredits = 1000000;
    mapping(address => mapping(string => uint256)) public balances;
    mapping(address => string) public merchantCategories;
    mapping(address => bool) public isMerchant;
    mapping(address => bool) public isStudent;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyStudent() {
        require(isStudent[msg.sender], "Only students can call this function");
        _;
    }

    modifier onlyMerchant() {
        require(isMerchant[msg.sender], "Only merchants can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
        balances[owner]["all"] = totalCredits;
    }

    // This function assigns credits of particular category to student getting the scholarship
    function grantScholarship(address studentAddress, uint256 credits, string memory category) public onlyOwner {
        require(
            keccak256(abi.encodePacked(category)) == keccak256(abi.encodePacked("meal"))
                || keccak256(abi.encodePacked(category)) == keccak256(abi.encodePacked("academics"))
                || keccak256(abi.encodePacked(category)) == keccak256(abi.encodePacked("sports"))
                || keccak256(abi.encodePacked(category)) == keccak256(abi.encodePacked("all")),
            "Invalid category"
        );
        balances[owner]["all"] -= credits;
        balances[studentAddress][category] += credits;
        isStudent[studentAddress] = true;
    }

    // This function is used to register a new merchant under given category
    function registerMerchantAddress(address merchantAddress, string memory category) public onlyOwner {
        require(
            keccak256(abi.encodePacked(category)) == keccak256(abi.encodePacked("meal"))
                || keccak256(abi.encodePacked(category)) == keccak256(abi.encodePacked("academics"))
                || keccak256(abi.encodePacked(category)) == keccak256(abi.encodePacked("sports")),
            "Invalid category"
        );
        merchantCategories[merchantAddress] = category;
        isMerchant[merchantAddress] = true;
    }

    // This function is used to deregister an existing merchant
    function deregisterMerchantAddress(address merchantAddress) public onlyOwner {
        isMerchant[merchantAddress] = false;
        delete merchantCategories[merchantAddress];
    }

    // This function is used to revoke the scholarship of a student
    function revokeScholarship(address studentAddress) public onlyOwner {
        balances[owner]["all"] += balances[studentAddress]["meal"] + balances[studentAddress]["academics"]
            + balances[studentAddress]["sports"] + balances[studentAddress]["all"];
        balances[studentAddress]["meal"] = 0;
        balances[studentAddress]["academics"] = 0;
        balances[studentAddress]["sports"] = 0;
        balances[studentAddress]["all"] = 0;
        isStudent[studentAddress] = false;
    }

    // Students can use this function to transfer credits only to registered merchants
    function spend(address merchantAddress, uint256 amount) public onlyStudent {
        require(isMerchant[merchantAddress], "Merchant is not registered");
        string memory category = merchantCategories[merchantAddress];
        if (keccak256(abi.encodePacked(category)) == keccak256(abi.encodePacked("meal"))) {
            if (balances[msg.sender]["meal"] >= amount) {
                balances[msg.sender]["meal"] -= amount;
            } else {
                uint256 remaining = amount - balances[msg.sender]["meal"];
                balances[msg.sender]["meal"] = 0;
                balances[msg.sender]["all"] -= remaining;
            }
        } else if (keccak256(abi.encodePacked(category)) == keccak256(abi.encodePacked("academics"))) {
            if (balances[msg.sender]["academics"] >= amount) {
                balances[msg.sender]["academics"] -= amount;
            } else {
                uint256 remaining = amount - balances[msg.sender]["academics"];
                balances[msg.sender]["academics"] = 0;
                balances[msg.sender]["all"] -= remaining;
            }
        } else if (keccak256(abi.encodePacked(category)) == keccak256(abi.encodePacked("sports"))) {
            if (balances[msg.sender]["sports"] >= amount) {
                balances[msg.sender]["sports"] -= amount;
            } else {
                uint256 remaining = amount - balances[msg.sender]["sports"];
                balances[msg.sender]["sports"] = 0;
                balances[msg.sender]["all"] -= remaining;
            }
        }
        balances[merchantAddress]["all"] += amount;
    }

    // This function is used to see the available credits assigned.
    function checkBalance(string memory category) public view returns (uint256) {
        return balances[msg.sender][category];
    }

    // This function is used to see the category under which Merchants are registered
    function showCategory() public view onlyMerchant returns (string memory) {
        return merchantCategories[msg.sender];
    }
}
