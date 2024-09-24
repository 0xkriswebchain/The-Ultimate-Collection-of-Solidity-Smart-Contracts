// Gavin, the CEO of a company, has hired you as an intern.
// To assess your proficiency in basic Solidity and mathematics,
// he has assigned you a task.

// Your task is to implement a smart contract that computes the greatest common divisor (GCD) of two unsigned integers.
// Given two positive integers a and b,
// the GCD of a and b is defined as the greatest positive integer that divides both a and b without leaving a remainder.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract GCDTest {
    // This function calculates the GCD (Greatest Common Divisor)
    function gcd(uint256 a, uint256 b) public pure returns (uint256) {
        // The function uses the Euclidean algorithm to compute the GCD
        // The algorithm works by repeatedly replacing the larger number by the remainder of the division of the larger number
        // by the smaller number until the remainder is zero.
        // The last non-zero remainder is the GCD of the original two numbers.
        while (b != 0) {
            uint256 temp = b;
            b = a % b;
            a = temp;
        }
        return a;
    }
}
