// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// In mathematical terms, the sequence Fn of Fibonacci numbers is defined by the recurrence relation:
// Fn = Fn-1 + Fn-2 with seed values and F0 = 0 and F1 = 1 .

contract Fibonacci {
    //To find the value of n+1 th Fibonacci number
    // This function should take 1 parameter of type uint256, n, as input
    // and output the value of Fn in the fibonacci sequence as described above.
    function fibonacci(uint256 n) public pure returns (uint256) {
        if (n == 0) {
            return 0;
        }
        if (n == 1) {
            return 1;
        }
        uint256 a = 0;
        uint256 b = 1;
        for (uint256 i = 2; i <= n; i++) {
            uint256 temp = a + b;
            a = b;
            b = temp;
        }
        return b;
    }
}
