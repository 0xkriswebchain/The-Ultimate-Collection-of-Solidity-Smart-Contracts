// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// Two's Complement is a mathematical operation on binary numbers,
// as well as a binary signed number representation based on this operation.
// Its wide use in computing makes it the most important example of a radix complement.

// In an 8-bit Two's Complement system, the positive numbers from 0 to 127 are represented as usual in binary form (00000000 to 01111111).
// The negative numbers from -1 to -128 are represented as the two's complement of their absolute values.

// The Two's Complement of a binary number is calculated by inverting all the bits and then adding 1 (binary addition)
// to the result. For example, to get the Two's Complement of -5 , we first write 5 in binary (00000101),
// then we invert the bits (11111010), and finally we add 1 (11111011). So, -5 is represented as 11111011 in an 8-bit
// two's complement system.

// You are required to modify your previous code to find the 8-bit Two's Complement representation of a number if
// the given number is negative. The input number will be a signed integer ranging from -128 to 127.

contract ToBinary {
    function toBinary(int256 n) public pure returns (string memory) {
        require(n >= -128 && n <= 127, "Input out of range");

        bytes memory binary = new bytes(8);
        uint256 num;

        if (n < 0) {
            num = uint256(int256(-n));
            num = ~num + 1; // Two's complement
        } else {
            num = uint256(n);
        }

        for (uint256 i = 0; i < 8; i++) {
            binary[7 - i] = (num & 1 == 1) ? bytes1("1") : bytes1("0");
            num >>= 1;
        }

        return string(binary);
    }
}
