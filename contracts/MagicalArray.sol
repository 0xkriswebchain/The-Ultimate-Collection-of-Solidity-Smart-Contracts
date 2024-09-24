// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Gavin has a magical array of integers that start changing every hour since its creation.
// These changes follow a specific rule,
// where after n hours since creation, all the numbers in the array become n times the numbers at the time of creation.
// For example, if the array's values were a0, a1, a2,... at the time of creation (i.e., at 0th hour), then after n hours,
// the array's values will be n*a0, n*a1, n*a2,....
// Gavin wants you to develop a smart contract that can determine the value of the ith integer in the array (i.e., a[i])
// after n hours.

contract MagicalArray {
    // Function to find the value of the ith integer in the array after n hours
    // This function returns the value of a[ind] after hrs number of hours.
    function findValue(int256[] memory a, uint256 ind, uint256 hrs) public pure returns (int256) {
        // Ensure the index is within the bounds of the array
        require(ind < a.length, "Index out of bounds");

        // Calculate the value after hrs hours
        int256 result = a[ind] * int256(hrs);

        return result;
    }
}
