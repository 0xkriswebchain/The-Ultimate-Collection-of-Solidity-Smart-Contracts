// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SolahParchiThap
 * @dev This contract represents a card game called "Solah Parchi Thap".
 * The game involves 16 cards and specific rules for gameplay.
 *
 * @notice Ensure to review the rules and logic implemented in this contract
 * to understand the gameplay mechanics.
 *
 * @dev The contract is located at /home/krischain/problems/contracts/16ParchiCardGame(diff).sol
 */
contract SolahParchiThap {
    address public owner;
    address[4] public players;
    uint8 public turnIndex;
    uint8[4][4] public gameState;

    /*
     * @title 16ParchiCardGame
     * @dev This contract implements a card game where players can win matches.
     * The `wins` mapping keeps track of the number of wins for each player.
     * 
     * @notice The `wins` mapping is public, allowing anyone to query the number of wins for a specific player.
     * The key is the player's address, and the value is the number of wins.
     */
    mapping(address => uint256) public wins;
    uint256 public gameStartTime;
    bool public gameActive;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyPlayer() {
        require(isPlayer(msg.sender), "Only players can call this function");
        _;
    }

    modifier gameInProgress() {
        require(gameActive, "No game in progress");
        _;
    }

    function startGame(address player1, address player2, address player3, address player4) public onlyOwner {
        require(!isPlayer(owner), "Owner cannot be a player");
        players = [player1, player2, player3, player4];
        turnIndex = 0;
        gameStartTime = block.timestamp;
        gameActive = true;
        distributeParchis();
    }

    function setState(address[4] memory _players, uint8[4][4] memory _state) public onlyOwner {
        require(!gameActive, "Game already in progress");
        players = _players;
        gameState = _state;
        turnIndex = 0;
        gameActive = true;
    }

    function passParchi(uint8 _type) public onlyPlayer gameInProgress {
        require(_type >= 1 && _type <= 4, "Invalid parchi type");
        uint8 playerIndex = getPlayerIndex(msg.sender);
        require(gameState[playerIndex][_type - 1] > 0, "Player does not have this parchi");

        gameState[playerIndex][_type - 1]--;
        uint8 nextPlayerIndex = (playerIndex + 1) % 4;
        gameState[nextPlayerIndex][_type - 1]++;
        turnIndex = nextPlayerIndex;
    }

    function endGame() public onlyPlayer gameInProgress {
        require(block.timestamp >= gameStartTime + 1 hours, "Cannot end game before 1 hour");
        gameActive = false;
    }

    function claimWin() public onlyPlayer gameInProgress {
        uint8 playerIndex = getPlayerIndex(msg.sender);
        for (uint8 i = 0; i < 4; i++) {
            if (gameState[playerIndex][i] == 4) {
                wins[msg.sender]++;
                gameActive = false;
                return;
            }
        }
        revert("Player does not have 4 parchis of the same type");
    }

    function getState() public view onlyOwner gameInProgress returns (address[4] memory, address, uint8[4][4] memory) {
        return (players, players[turnIndex], gameState);
    }

    function getWins(address player) public view returns (uint256) {
        return wins[player];
    }

    function myParchis() public view onlyPlayer gameInProgress returns (uint8[4] memory) {
        uint8 playerIndex = getPlayerIndex(msg.sender);
        return gameState[playerIndex];
    }

    function isPlayer(address addr) internal view returns (bool) {
        for (uint8 i = 0; i < 4; i++) {
            if (players[i] == addr) {
                return true;
            }
        }
        return false;
    }

    function getPlayerIndex(address addr) internal view returns (uint8) {
        for (uint8 i = 0; i < 4; i++) {
            if (players[i] == addr) {
                return i;
            }
        }
        revert("Address is not a player");
    }

    function distributeParchis() internal {
        uint8[16] memory allParchis = [1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4];
        for (uint8 i = 0; i < 16; i++) {
            uint8 j = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, i))) % 16);
            (allParchis[i], allParchis[j]) = (allParchis[j], allParchis[i]);
        }
        for (uint8 i = 0; i < 4; i++) {
            for (uint8 j = 0; j < 4; j++) {
                gameState[i][j] = 0;
            }
        }
        for (uint8 i = 0; i < 16; i++) {
            gameState[i / 4][allParchis[i] - 1]++;
        }
    }
}
