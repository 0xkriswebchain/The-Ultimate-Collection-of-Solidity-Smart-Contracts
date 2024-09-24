// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract DWGotTalent {
    address public owner;
    address[] public judges;
    address[] public finalists;
    uint256 public judgeWeightage;
    uint256 public audienceWeightage;
    bool public votingStarted;
    bool public votingEnded;

    mapping(address => uint256) public votes;
    mapping(address => address) public lastVote;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier votingNotStarted() {
        require(!votingStarted, "Voting already started");
        _;
    }

    modifier votingInProgress() {
        require(votingStarted && !votingEnded, "Voting not in progress");
        _;
    }

    modifier votingHasEnded() {
        require(votingEnded, "Voting not ended");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function selectJudges(address[] memory arrayOfAddresses) public onlyOwner votingNotStarted {
        require(arrayOfAddresses.length > 0, "Judges array cannot be empty");
        judges = arrayOfAddresses;
    }

    function inputWeightage(uint256 _judgeWeightage, uint256 _audienceWeightage) public onlyOwner votingNotStarted {
        require(_judgeWeightage > 0 && _audienceWeightage > 0, "Weightages must be greater than zero");
        judgeWeightage = _judgeWeightage;
        audienceWeightage = _audienceWeightage;
    }

    function selectFinalists(address[] memory arrayOfAddresses) public onlyOwner votingNotStarted {
        require(arrayOfAddresses.length > 0, "Finalists array cannot be empty");
        finalists = arrayOfAddresses;
    }

    function startVoting() public onlyOwner votingNotStarted {
        require(judges.length > 0, "Judges must be set");
        require(finalists.length > 0, "Finalists must be set");
        require(judgeWeightage > 0 && audienceWeightage > 0, "Weightages must be set");
        votingStarted = true;
    }

    function castVote(address finalistAddress) public votingInProgress {
        require(isFinalist(finalistAddress), "Not a valid finalist");
        if (lastVote[msg.sender] != address(0)) {
            votes[lastVote[msg.sender]] -= getWeightage(msg.sender);
        }
        votes[finalistAddress] += getWeightage(msg.sender);
        lastVote[msg.sender] = finalistAddress;
    }

    function endVoting() public onlyOwner votingInProgress {
        votingEnded = true;
    }

    function showResult() public view votingHasEnded returns (address[] memory) {
        uint256 maxVotes = 0;
        uint256 count = 0;
        for (uint256 i = 0; i < finalists.length; i++) {
            if (votes[finalists[i]] > maxVotes) {
                maxVotes = votes[finalists[i]];
                count = 1;
            } else if (votes[finalists[i]] == maxVotes) {
                count++;
            }
        }

        address[] memory winners = new address[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < finalists.length; i++) {
            if (votes[finalists[i]] == maxVotes) {
                winners[index] = finalists[i];
                index++;
            }
        }
        return winners;
    }

    function isFinalist(address addr) internal view returns (bool) {
        for (uint256 i = 0; i < finalists.length; i++) {
            if (finalists[i] == addr) {
                return true;
            }
        }
        return false;
    }

    function isJudge(address addr) internal view returns (bool) {
        for (uint256 i = 0; i < judges.length; i++) {
            if (judges[i] == addr) {
                return true;
            }
        }
        return false;
    }

    function getWeightage(address voter) internal view returns (uint256) {
        if (isJudge(voter)) {
            return judgeWeightage;
        } else {
            return audienceWeightage;
        }
    }
}
