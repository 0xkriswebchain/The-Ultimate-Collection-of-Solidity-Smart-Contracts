// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DAOMembership {
    address public owner;
    mapping(address => bool) public members;
    mapping(address => bool) public applicants;
    mapping(address => uint256) public approvals;
    uint256 public memberCount;

    modifier onlyMember() {
        require(members[msg.sender], "Only members can call this function");
        _;
    }

    modifier onlyNonMember() {
        require(!members[msg.sender], "Members cannot call this function");
        require(!applicants[msg.sender], "Already applied for membership");
        _;
    }

    constructor() {
        owner = msg.sender;
        members[owner] = true;
        memberCount = 1;
    }

    function applyForEntry() public onlyNonMember {
        applicants[msg.sender] = true;
    }

    function approveEntry(address applicant) public onlyMember {
        require(applicants[applicant], "Applicant has not applied or is already a member");
        require(!members[applicant], "Applicant is already a member");

        approvals[applicant] += 1;

        if (approvals[applicant] * 100 / memberCount >= 30) {
            members[applicant] = true;
            memberCount += 1;
            delete applicants[applicant];
            delete approvals[applicant];
        }
    }

    function isMember(address participant) public view onlyMember returns (bool) {
        return members[participant];
    }

    function totalMembers() public view onlyMember returns (uint256) {
        return memberCount;
    }
}
