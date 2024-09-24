// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RemoveVowels {
    function removeVowels(string memory _input) public pure returns (string memory) {
        bytes memory inputBytes = bytes(_input);
        bytes memory resultBytes = new bytes(inputBytes.length);
        uint256 resultIndex = 0;

        for (uint256 i = 0; i < inputBytes.length; i++) {
            bytes1 char = inputBytes[i];
            if (
                char != "a" && char != "e" && char != "i" && char != "o" && char != "u" && char != "A" && char != "E"
                    && char != "I" && char != "O" && char != "U"
            ) {
                resultBytes[resultIndex] = char;
                resultIndex++;
            }
        }

        bytes memory trimmedResultBytes = new bytes(resultIndex);
        for (uint256 i = 0; i < resultIndex; i++) {
            trimmedResultBytes[i] = resultBytes[i];
        }

        return string(trimmedResultBytes);
    }
}
