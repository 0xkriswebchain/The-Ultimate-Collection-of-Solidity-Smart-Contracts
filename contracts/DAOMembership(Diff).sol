// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DAOMembership {
    address public owner;
    mapping(address => bool) public members;
    mapping(address => bool) public applicants;
    mapping(address => uint256) public approvals;
    mapping(address => uint256) public disapprovals;
    mapping(address => uint256) public removalVotes;
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

    modifier onlyIfNotEmpty() {
        require(memberCount > 0, "DAO has no members");
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

    function approveEntry(address applicant) public onlyMember onlyIfNotEmpty {
        require(applicants[applicant], "Applicant has not applied or is already a member");
        require(!members[applicant], "Applicant is already a member");

        approvals[applicant] += 1;

        if (approvals[applicant] * 100 / memberCount >= 30) {
            members[applicant] = true;
            memberCount += 1;
            delete applicants[applicant];
            delete approvals[applicant];
            delete disapprovals[applicant];
        }
    }

    function disapproveEntry(address applicant) public onlyMember onlyIfNotEmpty {
        require(applicants[applicant], "Applicant has not applied or is already a member");
        require(!members[applicant], "Applicant is already a member");

        disapprovals[applicant] += 1;

        if (disapprovals[applicant] * 100 / memberCount >= 70) {
            delete applicants[applicant];
            delete approvals[applicant];
            delete disapprovals[applicant];
        }
    }

    function removeMember(address memberToRemove) public onlyMember onlyIfNotEmpty {
        require(members[memberToRemove], "Address is not a member");
        require(memberToRemove != msg.sender, "Cannot remove yourself");

        removalVotes[memberToRemove] += 1;

        if (removalVotes[memberToRemove] * 100 / (memberCount - 1) >= 70) {
            members[memberToRemove] = false;
            memberCount -= 1;
            delete removalVotes[memberToRemove];
        }
    }

    function leave() public onlyMember onlyIfNotEmpty {
        members[msg.sender] = false;
        memberCount -= 1;
    }

    function isMember(address participant) public view onlyMember onlyIfNotEmpty returns (bool) {
        return members[participant];
    }

    function totalMembers() public view onlyMember onlyIfNotEmpty returns (uint256) {
        return memberCount;
    }
}
