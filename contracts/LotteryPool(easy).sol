// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LotteryPool {
    address[] public participants;
    address public previousWinner;
    uint256 public constant ENTRY_FEE = 0.1 ether;
    uint256 public constant MAX_PARTICIPANTS = 5;

    function enter() public payable {
        require(msg.value == ENTRY_FEE, "Entry fee is 0.1 ether");
        require(!isParticipant(msg.sender), "Already entered in the current lottery");

        participants.push(msg.sender);

        if (participants.length == MAX_PARTICIPANTS) {
            selectWinner();
        }
    }

    function viewParticipants() public view returns (address[] memory, uint256) {
        return (participants, participants.length);
    }

    function viewPreviousWinner() public view returns (address) {
        require(previousWinner != address(0), "No lottery has been completed yet");
        return previousWinner;
    }

    function isParticipant(address _participant) internal view returns (bool) {
        for (uint256 i = 0; i < participants.length; i++) {
            if (participants[i] == _participant) {
                return true;
            }
        }
        return false;
    }

    function selectWinner() internal {
        uint256 winnerIndex = random() % MAX_PARTICIPANTS;
        previousWinner = participants[winnerIndex];
        payable(previousWinner).transfer(address(this).balance);
        delete participants;
    }

    function random() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, participants)));
    }
}
