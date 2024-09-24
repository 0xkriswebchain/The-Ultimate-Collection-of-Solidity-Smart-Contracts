// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DiamondTracking {
    // Mapping to store the count of diamonds by their weight
    mapping(uint256 => uint256) private diamondCount;

    // Function to import diamonds
    function importDiamonds(uint256[] memory weights) public {
        for (uint256 i = 0; i < weights.length; i++) {
            diamondCount[weights[i]]++;
        }
    }

    // Function to get the number of diamonds of a specific weight
    function availableDiamonds(uint256 weight) public view returns (uint256) {
        return diamondCount[weight];
    }
}
