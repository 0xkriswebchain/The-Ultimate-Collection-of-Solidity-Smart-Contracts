// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FindEvenNumber {
    function EvenNumber(uint256 number) public pure returns (bool) {
        if (number % 2 == 0) {
            return true;
        } else {
            return false;
        }
    }
}
