// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LotteryPool {
    address public gavin;
    address[] public participants;
    address public previousWinner;
    uint256 public earnings;
    uint256 public constant ENTRY_FEE_BASE = 0.1 ether;
    uint256 public constant ENTRY_FEE_INCREMENT = 0.01 ether;
    uint256 public constant MAX_PARTICIPANTS = 5;
    mapping(address => uint256) public wins;

    constructor() {
        gavin = msg.sender;
    }

    function enter() public payable {
        require(msg.sender != gavin, "Gavin cannot enter the lottery");
        uint256 entryFee = ENTRY_FEE_BASE + (wins[msg.sender] * ENTRY_FEE_INCREMENT);
        require(msg.value == entryFee, "Incorrect entry fee");
        require(!isParticipant(msg.sender), "Already entered in the current lottery");

        uint256 fee = (entryFee * 10) / 100;
        earnings += fee;
        payable(gavin).transfer(fee);

        participants.push(msg.sender);
        if (participants.length == MAX_PARTICIPANTS) {
            selectWinner();
        }
    }

    function withdraw() public {
        require(isParticipant(msg.sender), "Not part of the current pool");
        uint256 entryFee = ENTRY_FEE_BASE + (wins[msg.sender] * ENTRY_FEE_INCREMENT);
        uint256 refundAmount = (entryFee * 90) / 100;
        removeParticipant(msg.sender);
        payable(msg.sender).transfer(refundAmount);
    }

    function viewParticipants() public view returns (address[] memory, uint256) {
        return (participants, participants.length);
    }

    function viewPreviousWinner() public view returns (address) {
        require(previousWinner != address(0), "No lottery has been completed yet");
        return previousWinner;
    }

    function viewEarnings() public view returns (uint256) {
        require(msg.sender == gavin, "Only Gavin can view earnings");
        return earnings;
    }

    function viewPoolBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function isParticipant(address _participant) internal view returns (bool) {
        for (uint256 i = 0; i < participants.length; i++) {
            if (participants[i] == _participant) {
                return true;
            }
        }
        return false;
    }

    function removeParticipant(address _participant) internal {
        for (uint256 i = 0; i < participants.length; i++) {
            if (participants[i] == _participant) {
                participants[i] = participants[participants.length - 1];
                participants.pop();
                break;
            }
        }
    }

    function selectWinner() internal {
        uint256 winnerIndex = random() % MAX_PARTICIPANTS;
        previousWinner = participants[winnerIndex];
        wins[previousWinner]++;
        payable(previousWinner).transfer(address(this).balance);
        delete participants;
    }

    function random() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, participants)));
    }
}
