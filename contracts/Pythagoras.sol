// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Given 3 numbers, we want to check wheather it is possible to create a right angled triangle
// such that the lengths of the 3 sides of the triangle are same as the 3 numbers.
// Create a smart contract which has the following public function :

contract RightAngledTriangle {
    // To check if a triangle with side lengths a, b, c is a right-angled triangle
    // This function must return true if it is possible for a right angled triangle to have the sides of length equal a, b and c respectively.
    // If not, then it must return false.
    function check(uint256 a, uint256 b, uint256 c) public pure returns (bool) {
        // A triangle cannot have a side with length 0
        if (a == 0 || b == 0 || c == 0) {
            return false;
        }

        // Sort the sides so that a <= b <= c
        if (a > b) {
            (a, b) = (b, a);
        }
        if (b > c) {
            (b, c) = (c, b);
        }
        if (a > b) {
            (a, b) = (b, a);
        }

        // Check the Pythagorean theorem
        return (c * c) == (a * a) + (b * b);
    }
}
