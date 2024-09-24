// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title ParchiThap - A simple card game contract
/// @notice This contract allows players to play a card game called ParchiThap
/// @dev This contract is for demonstration purposes and may not be suitable for production use
contract ParchiThap {
    address public owner; // Owner of the contract
    address[4] public players; // Array of players
    uint8[4][4] public gameState; // 2D array representing the game state
    uint256 public turnIndex; // Index of the current player's turn
    uint256 public startTime; // Timestamp when the game started
    mapping(address => uint256) public wins; // Mapping to track the number of wins for each player
    bool public gameInProgress; // Boolean to check if a game is in progress

    /// @dev Modifier to restrict access to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    /// @dev Modifier to restrict access to players
    modifier onlyPlayer() {
        require(isPlayer(msg.sender), "Only players can call this function");
        _;
    }

    /// @dev Modifier to check if a game is in progress
    modifier isGameInProgress() {
        require(gameInProgress, "No game in progress");
        _;
    }

    /// @dev Modifier to validate the game state
    modifier validState(uint8[4][4] memory _state) {
        require(isValidState(_state), "Invalid game state");
        _;
    }

    /// @notice Constructor to set the owner of the contract
    constructor() {
        owner = msg.sender;
    }

    /// @notice Set the initial state of the game
    /// @param _players Array of player addresses
    /// @param _state Initial game state
    /// @dev Only the owner can call this function and the game state must be valid
    function setState(address[4] memory _players, uint8[4][4] memory _state) public onlyOwner validState(_state) {
        require(!gameInProgress, "Game already in progress");
        players = _players;
        gameState = _state;
        turnIndex = 0;
        startTime = block.timestamp;
        gameInProgress = true;
    }

    /// @notice Pass a parchi to the next player
    /// @param _type Type of parchi to pass
    /// @dev Only players can call this function and the game must be in progress
    function passParchi(uint8 _type) public onlyPlayer isGameInProgress {
        require(gameState[turnIndex][_type] > 0, "Player does not have this parchi");
        gameState[turnIndex][_type]--;
        turnIndex = (turnIndex + 1) % 4;
        gameState[turnIndex][_type]++;
    }

    /// @notice End the game
    /// @dev Only players can call this function and the game must be in progress for at least 1 hour
    function endGame() public onlyPlayer isGameInProgress {
        require(block.timestamp >= startTime + 1 hours, "Cannot end game before 1 hour");
        gameInProgress = false;
    }

    /// @notice Claim a win if the player has 4 parchis of the same type
    /// @dev Only players can call this function and the game must be in progress
    function claimWin() public onlyPlayer isGameInProgress {
        uint8[4] memory playerParchis = gameState[turnIndex];
        for (uint8 i = 0; i < 4; i++) {
            if (playerParchis[i] == 4) {
                wins[msg.sender]++;
                gameInProgress = false;
                return;
            }
        }
        revert("Player does not have 4 parchis of the same type");
    }

    /// @notice Get the current state of the game
    /// @return Array of player addresses, current player's address, and the game state
    /// @dev Only the owner can call this function and the game must be in progress
    function getState()
        public
        view
        onlyOwner
        isGameInProgress
        returns (address[4] memory, address, uint8[4][4] memory)
    {
        return (players, players[turnIndex], gameState);
    }

    /// @notice Get the number of wins for a player
    /// @param player Address of the player
    /// @return Number of wins for the player
    function getWins(address player) public view returns (uint256) {
        return wins[player];
    }

    /// @notice Get the parchis of the caller
    /// @return Array of parchis for the caller
    /// @dev Only players can call this function and the game must be in progress
    function myParchis() public view onlyPlayer isGameInProgress returns (uint8[4] memory) {
        for (uint256 i = 0; i < 4; i++) {
            if (players[i] == msg.sender) {
                return gameState[i];
            }
        }
        revert("Player not found");
    }

    /// @notice Check if an address is a player
    /// @param addr Address to check
    /// @return True if the address is a player, false otherwise
    function isPlayer(address addr) internal view returns (bool) {
        for (uint256 i = 0; i < 4; i++) {
            if (players[i] == addr) {
                return true;
            }
        }
        return false;
    }

    /// @notice Validate the game state
    /// @param _state Game state to validate
    /// @return True if the game state is valid, false otherwise
    function isValidState(uint8[4][4] memory _state) internal pure returns (bool) {
        for (uint256 i = 0; i < 4; i++) {
            uint8 totalParchis = 0;
            for (uint256 j = 0; j < 4; j++) {
                totalParchis += _state[i][j];
            }
            if (totalParchis < 3 || totalParchis > 5) {
                return false;
            }
        }
        return true;
    }
}
