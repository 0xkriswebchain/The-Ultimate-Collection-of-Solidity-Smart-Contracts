// LCM (Least Common Multiple) is the smallest multiple that two or more numbers have in common. In other words, 
// it is the smallest number that is a multiple of both of the given numbers.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract LCM {
    //this function calculates the LCM
    function lcm(uint a, uint b) public pure returns (uint) {
        // Calculate the greatest common divisor (GCD) first
        uint gcd = Gcd(a, b);

        // The LCM is the product of the two numbers divided by their GCD
        return (a / gcd) * b;
    }

    // Helper function to calculate the GCD recursively
    function Gcd(uint a, uint b) private pure returns (uint) {
        if (b == 0) {
            return a;
        }
        return Gcd(b, a % b);
    }
}