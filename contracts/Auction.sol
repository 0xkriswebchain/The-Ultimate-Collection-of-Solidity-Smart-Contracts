// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract Auction {
    struct AuctionItem {
        uint256 startingPrice;
        uint256 highestBid;
        address highestBidder;
        uint256 endTime;
        bool active;
    }

    mapping(uint256 => AuctionItem) public auctions;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier auctionExists(uint256 itemNumber) {
        require(auctions[itemNumber].endTime != 0, "Auction does not exist");
        _;
    }

    modifier auctionActive(uint256 itemNumber) {
        require(auctions[itemNumber].active, "Auction is not active");
        _;
    }

    constructor() {
        owner = msg.sender;
    }
    // This function allows the contract owner to create a new auction.
    // It takes three parameters: itemNumber (the number of the item for auction).
    // The itemNumber should be unique for each item, startingPrice in wei(the starting price of the auction)
    // the startingPrice cannot be 0, and duration (the duration of the auction in seconds) cannot be 0.
    // The function does not return anything.The auction starts as soon as this function is called.

    function createAuction(uint256 itemNumber, uint256 startingPrice, uint256 duration) public onlyOwner {
        require(startingPrice > 0, "Starting price must be greater than 0");
        require(duration > 0, "Duration must be greater than 0");
        require(auctions[itemNumber].endTime == 0, "Auction already exists");

        auctions[itemNumber] = AuctionItem({
            startingPrice: startingPrice,
            highestBid: 0,
            highestBidder: address(0),
            endTime: block.timestamp + duration,
            active: true
        });
    }

    // This is a payable function allows a user to place a bid on an item.
    // It takes two parameters: itemNumber (the number of the item for which the bid is being placed)
    // and bidAmount (the amount of the bid).
    // The function does not return anything.

    function bid(uint256 itemNumber, uint256 bidAmount)
        public
        payable
        auctionExists(itemNumber)
        auctionActive(itemNumber)
    {
        AuctionItem storage auction = auctions[itemNumber];
        require(bidAmount > auction.highestBid && bidAmount >= auction.startingPrice, "Bid amount too low");
        require(msg.value == bidAmount, "Incorrect bid amount sent");

        if (auction.highestBidder != address(0)) {
            payable(auction.highestBidder).transfer(auction.highestBid);
        }

        auction.highestBid = bidAmount;
        auction.highestBidder = msg.sender;
    }

    // This function allows the contract owner to cancel an auction. It takes one parameter:
    // itemNumber (the number of the item for which the auction is being cancelled).
    // An auction can only be cancelled if the auction is still active.
    // The function does not return anything.
    function cancelAuction(uint256 itemNumber) public onlyOwner auctionExists(itemNumber) auctionActive(itemNumber) {
        auctions[itemNumber].active = false;
        if (auctions[itemNumber].highestBidder != address(0)) {
            payable(auctions[itemNumber].highestBidder).transfer(auctions[itemNumber].highestBid);
        }
    }

    function checkAuctionActive(uint256 itemNumber) public view auctionExists(itemNumber) returns (bool) {
        return auctions[itemNumber].active;
    }

    function timeLeft(uint256 itemNumber) public view auctionExists(itemNumber) returns (uint256) {
        require(auctions[itemNumber].active, "Auction is not active");
        if (block.timestamp >= auctions[itemNumber].endTime) {
            return 0;
        }
        return auctions[itemNumber].endTime - block.timestamp;
    }

    function checkHighestBidder(uint256 itemNumber) public view auctionExists(itemNumber) returns (address) {
        return auctions[itemNumber].highestBidder;
    }

    function checkActiveBidPrice(uint256 itemNumber) public view auctionExists(itemNumber) returns (uint256) {
        require(auctions[itemNumber].active, "Auction is not active");
        return auctions[itemNumber].highestBid;
    }
}
