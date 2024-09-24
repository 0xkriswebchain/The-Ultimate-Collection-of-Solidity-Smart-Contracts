// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract chocolateShop {
    // state variables
    uint256 public totalChocolatesInBag;
    int256[] public totalTransactions;

    // events
    event ChocolatesPurchased(uint256 _number);
    event ChocolatesSold(uint256 _number);

    function buyChocolates(uint256 n) public {
        totalChocolatesInBag += n;
        totalTransactions.push(int256(n));
        emit ChocolatesPurchased(n);
    }

    function sellChocolates(uint256 n) public {
        require(totalChocolatesInBag >= n, "Cannot Exceed the Number");
        totalChocolatesInBag -= n;
        totalTransactions.push(-int256(n));
        emit ChocolatesSold(n);
    }

    function getChocolatesInBag() public view returns (uint256) {
        return totalChocolatesInBag;
    }

    function transaction(uint256 n) public view returns (int256) {
        require(totalTransactions.length > n, "The number is invalid");
        return totalTransactions[n];
    }

    function numberOfTransactions() public view returns (uint256) {
        return totalTransactions.length;
    }
}
