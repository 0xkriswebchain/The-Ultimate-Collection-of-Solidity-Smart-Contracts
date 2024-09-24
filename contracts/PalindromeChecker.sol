// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PalindromeChecker {
    // To check if a given string is palindrome or not
    function isPalindrome(string memory str) public pure returns (bool) {
        bytes memory bStr = bytes(str);
        uint256 len = bStr.length;
        bytes memory filteredStr = new bytes(len);
        uint256 j = 0;

        // Normalize the string: remove non-alphanumeric characters and convert to lowercase
        for (uint256 i = 0; i < len; i++) {
            bytes1 char = bStr[i];
            if ((char >= 0x41 && char <= 0x5A) || (char >= 0x61 && char <= 0x7A) || (char >= 0x30 && char <= 0x39)) {
                if (char >= 0x41 && char <= 0x5A) {
                    char = bytes1(uint8(char) + 32); // Convert uppercase to lowercase
                }
                filteredStr[j] = char;
                j++;
            }
        }

        // Check if the filtered string is a palindrome
        for (uint256 i = 0; i < j / 2; i++) {
            if (filteredStr[i] != filteredStr[j - 1 - i]) {
                return false;
            }
        }

        return true;
    }
}
