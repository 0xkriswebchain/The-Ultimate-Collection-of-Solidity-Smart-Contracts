// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Holi {
    // Mapping to store the maximum credit limit for each color
    mapping(string => uint256) public colorLimits;

    // Mapping to store the remaining credits for Shyam
    uint256 public remainingCredits;

    // Constructor to initialize the color limits and remaining credits
    constructor() {
        colorLimits["red"] = 40;
        colorLimits["blue"] = 40;
        colorLimits["green"] = 30;
        remainingCredits = 100;
    }

    // Function to buy a color
    function buyColour(string memory colour, uint256 price) public {
        // Check if the color is valid
        require(
            keccak256(abi.encodePacked(colour)) == keccak256(abi.encodePacked("red"))
                || keccak256(abi.encodePacked(colour)) == keccak256(abi.encodePacked("blue"))
                || keccak256(abi.encodePacked(colour)) == keccak256(abi.encodePacked("green")),
            "Invalid color"
        );

        // Check if the price is within the limit
        require(price <= colorLimits[colour], "Price exceeds the limit");

        // Check if Shyam has enough credits
        require(remainingCredits >= price, "Insufficient credits");

        // Update the remaining credits
        remainingCredits -= price;
    }

    // Function to get the remaining credits
    function credits() public view returns (uint256) {
        return remainingCredits;
    }
}
