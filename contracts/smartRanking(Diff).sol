// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StudentResults {
    struct Student {
        uint256 rollNumber;
        uint256 marks;
    }

    Student[] private students;
    mapping(uint256 => uint256) private rollNumberToIndex;

    function insertMarks(uint256 _rollNumber, uint256 _marks) public {
        Student memory newStudent = Student(_rollNumber, _marks);
        students.push(newStudent);
        rollNumberToIndex[_rollNumber] = students.length - 1;

        // Sort the array by marks in descending order
        for (uint256 i = students.length - 1; i > 0; i--) {
            if (students[i].marks > students[i - 1].marks) {
                Student memory temp = students[i];
                students[i] = students[i - 1];
                students[i - 1] = temp;
                rollNumberToIndex[students[i].rollNumber] = i;
                rollNumberToIndex[students[i - 1].rollNumber] = i - 1;
            } else {
                break;
            }
        }
    }

    function scoreByRank(uint256 rank) public view returns (uint256) {
        require(rank > 0 && rank <= students.length, "Invalid rank");
        return students[rank - 1].marks;
    }

    function rollNumberByRank(uint256 rank) public view returns (uint256) {
        require(rank > 0 && rank <= students.length, "Invalid rank");
        return students[rank - 1].rollNumber;
    }
}
