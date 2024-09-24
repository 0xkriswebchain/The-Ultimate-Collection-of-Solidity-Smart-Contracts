// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract FindArea {
    function squareArea(uint256 number) public pure returns (uint256) {
        require(number <= type(uint256).max / number, "Value too large");
        return number * number;
    }

    function rectangleArea(uint256 length, uint256 bredth) public pure returns (uint256) {
        require(length > 0 && bredth > 0, "Values cannot be zero");
        return length * bredth;
    }
}
