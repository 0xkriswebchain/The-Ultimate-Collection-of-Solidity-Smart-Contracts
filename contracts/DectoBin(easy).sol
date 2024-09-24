// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// You are tasked with writing a Solidity contract that takes any unsigned integer (ranging from 0 to 255) as input,
// converts it to an 8-bit binary representation, and returns the binary representation as a string.
// Example : Binary representation of 5 : “101”, 8 bit representation : “00000101”.

contract DecmimalsToBinary {
    function DecToBin(uint256 n) public pure returns (string memory) {
        // Check
        require(n <= 255, "Choose a Number between 0 and 255");

        bytes memory binary = new bytes(8);
        for (uint256 i = 0; i < 8; i++) {
            if (n & (1 << i) != 0) {
                binary[7 - i] = "1";
            } else {
                binary[7 - i] = "0";
            }
        }
        return string(binary);
    }
}
