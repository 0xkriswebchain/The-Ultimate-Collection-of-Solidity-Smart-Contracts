// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGamingEcosystemNFT {
    function mintNFT(address to) external;
    function burnNFT(uint256 tokenId) external;
    function transferNFT(uint256 tokenId, address from, address to) external;
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract BlockchainGamingEcosystem {
    address public owner;
    IGamingEcosystemNFT public nftContract;
    uint256 public nextTokenId = 0;

    struct Player {
        string userName;
        uint256 balance;
        uint256 numberOfNFTs;
    }

    struct Game {
        string gameName;
        uint256 currentPrice;
        bool exists;
    }

    mapping(address => Player) public players;
    mapping(string => address) public userNameToAddress;
    mapping(uint256 => Game) public games;
    mapping(uint256 => uint256) public assetToGame;
    mapping(uint256 => uint256) public assetToPrice;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyRegisteredPlayer() {
        require(bytes(players[msg.sender].userName).length > 0, "Only registered players can call this function");
        _;
    }

    constructor(address _nftAddress) {
        owner = msg.sender;
        nftContract = IGamingEcosystemNFT(_nftAddress);
    }

    function registerPlayer(string memory userName) public {
        require(msg.sender != owner, "Owner cannot register as a player");
        require(bytes(userName).length >= 3, "Username must be at least 3 characters long");
        require(userNameToAddress[userName] == address(0), "Username already taken");
        require(bytes(players[msg.sender].userName).length == 0, "Player already registered");

        players[msg.sender] = Player(userName, 1000, 0);
        userNameToAddress[userName] = msg.sender;
    }

    function createGame(string memory gameName, uint256 gameID) public onlyOwner {
        require(!games[gameID].exists, "Game ID already exists");
        games[gameID] = Game(gameName, 250, true);
    }

    function removeGame(uint256 gameID) public onlyOwner {
        require(games[gameID].exists, "Game does not exist");
        games[gameID].exists = false;

        for (uint256 tokenId = 0; tokenId < nextTokenId; tokenId++) {
            if (assetToGame[tokenId] == gameID) {
                uint256 price = assetToPrice[tokenId];
                players[owner].balance += price;
                players[owner].numberOfNFTs -= 1;
                nftContract.burnNFT(tokenId);
            }
        }
    }

    function buyAsset(uint256 gameID) public onlyRegisteredPlayer {
        require(games[gameID].exists, "Game does not exist");
        uint256 price = games[gameID].currentPrice;
        require(players[msg.sender].balance >= price, "Insufficient balance");

        players[msg.sender].balance -= price;
        players[msg.sender].numberOfNFTs += 1;
        nftContract.mintNFT(msg.sender);

        assetToGame[nextTokenId] = gameID;
        assetToPrice[nextTokenId] = price;
        nextTokenId++;

        games[gameID].currentPrice = price + (price / 10);
    }

    function sellAsset(uint256 tokenID) public onlyRegisteredPlayer {
        require(nftContract.ownerOf(tokenID) == msg.sender, "You do not own this asset");
        uint256 price = assetToPrice[tokenID];
        uint256 gameID = assetToGame[tokenID];

        players[msg.sender].balance += price;
        players[msg.sender].numberOfNFTs -= 1;
        nftContract.burnNFT(tokenID);

        games[gameID].currentPrice = price;
    }

    function transferAsset(uint256 tokenID, address to) public onlyRegisteredPlayer {
        require(nftContract.ownerOf(tokenID) == msg.sender, "You do not own this asset");
        require(bytes(players[to].userName).length > 0, "Recipient is not a registered player");

        players[msg.sender].numberOfNFTs -= 1;
        players[to].numberOfNFTs += 1;
        nftContract.transferNFT(tokenID, msg.sender, to);
    }

    function viewProfile(address playerAddress)
        public
        view
        returns (string memory userName, uint256 balance, uint256 numberOfNFTs)
    {
        Player memory player = players[playerAddress];
        return (player.userName, player.balance, player.numberOfNFTs);
    }

    function viewAsset(uint256 tokenID) public view returns (address player, string memory gameName, uint256 price) {
        address assetOwner = nftContract.ownerOf(tokenID);
        uint256 gameID = assetToGame[tokenID];
        string memory assetGameName = games[gameID].gameName;
        uint256 assetPrice = assetToPrice[tokenID];
        return (assetOwner, assetGameName, assetPrice);
    }
}
