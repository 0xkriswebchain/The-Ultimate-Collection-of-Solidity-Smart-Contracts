// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//task is to find the difference between 'n' and the closest prime number to it.
// The difference should be calculated as an absolute value.

contract leastPrimeDifference {
    function isPrime(uint256 num) internal pure returns (bool) {
        if (num <= 1) {
            return false;
        }
        for (uint256 i = 2; i * i <= num; i++) {
            if (num % i == 0) {
                return false;
            }
        }
        return true;
    }

    // This should be a pure function which takes a uint as a parameter
    // and returns a uint equal to the difference between n and the closest prime number to n.
    function primeDifference(uint256 n) public pure returns (uint256) {
        if (n == 0) {
            return 2;
        }
        if (n == 1) {
            return 1;
        }
        if (isPrime(n)) {
            return 0;
        }

        uint256 lower = n;
        uint256 higher = n;

        while (true) {
            if (isPrime(lower)) {
                break;
            }
            lower--;
        }

        while (true) {
            if (isPrime(higher)) {
                break;
            }
            higher++;
        }

        if (n - lower <= higher - n) {
            return n - lower;
        } else {
            return higher - n;
        }
    }
}
