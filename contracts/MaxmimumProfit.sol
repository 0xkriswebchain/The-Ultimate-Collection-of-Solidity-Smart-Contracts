// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract MaxProfit {
    // This function takes an array of prices and calculates the maximum profit
    //  It is guaranteed that the prices of all the shares never exceed or equal 2^256
    function maxProfit(uint256[] memory prices) public pure returns (uint256) {
        // Lets Consider the input array of prices: [7, 1, 5, 3, 6, 4].
        uint256 minPrice = type(uint256).max;
        uint256 maxProfitValue = 0;

        for (uint256 i = 0; i < prices.length; i++) {
            if (prices[i] < minPrice) {
                minPrice = prices[i];
            } else if (prices[i] - minPrice > maxProfitValue) {
                maxProfitValue = prices[i] - minPrice;
            }
        }

        return maxProfitValue;
    }
}
