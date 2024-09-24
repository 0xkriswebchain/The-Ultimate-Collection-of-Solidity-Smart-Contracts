// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract secondLargest {
    function findSecondLargest(int256[] memory _array) public pure returns (int256) {
        require(_array.length >= 2, "Array must have at least 2 values.");
        int256 maxNumber = _array[0];
        int256 secondLargestNum = _array[1];
        if (secondLargestNum > maxNumber) {
            (maxNumber, secondLargestNum) = (secondLargestNum, maxNumber);
        }

        for (uint256 i = 2; i < _array.length; i++) {
            if (_array[i] > maxNumber) {
                secondLargestNum = maxNumber;
                maxNumber = _array[i];
            } else if (_array[i] > secondLargestNum && _array[i] < maxNumber) {
                secondLargestNum = _array[i];
            }
        }
        return secondLargestNum;
    }
}
