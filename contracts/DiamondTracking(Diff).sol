// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract DiamondLedger {
    uint256[] public diamondWeights;

    // This function imports the diamonds
    function importDiamonds(uint256[] memory weights) public {
        for (uint256 i = 0; i < weights.length; i++) {
            require(weights[i] <= 1000, "Weight must be <= 1000");
            diamondWeights.push(weights[i]);
        }
    }

    // This function returns the total number of available diamonds as per the weight and offset
    function availableDiamonds(uint256 weight, uint256 allowance) public view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < diamondWeights.length; i++) {
            if (diamondWeights[i] >= weight - allowance && diamondWeights[i] <= weight + allowance) {
                count++;
            }
        }
        return count;
    }
}
