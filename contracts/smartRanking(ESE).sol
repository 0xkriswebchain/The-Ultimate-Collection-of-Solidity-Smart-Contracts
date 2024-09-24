// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StudentResults {
    // Mapping to store marks of each student by roll number
    mapping(uint256 => uint256) private studentMarks;

    // Variables to store the highest marks and the roll number of the topper
    uint256 private highestMarks = 0;
    uint256 private topperRollNumber = 0;
    bool private hasMarks = false;

    // Function to insert marks of a student
    function insertMarks(uint256 _rollNumber, uint256 _marks) public {
        studentMarks[_rollNumber] = _marks;
        hasMarks = true;

        // Check if the new marks are the highest
        if (_marks > highestMarks) {
            highestMarks = _marks;
            topperRollNumber = _rollNumber;
        }
    }

    // Function to get the highest marks
    function topperMarks() public view returns (uint256) {
        require(hasMarks, "No marks have been inserted yet.");
        return highestMarks;
    }

    // Function to get the roll number of the student with the highest marks
    function topperRollNum() public view returns (uint256) {
        require(hasMarks, "No marks have been inserted yet.");
        return topperRollNumber;
    }
}
