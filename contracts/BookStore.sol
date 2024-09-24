// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// Gavin is starting a new bookstore and wants to use a smart contract to securely store data and make the process easy for customers.
// Gavin needs functionalities to be enabled for customers to directly check the availability of books using the smart contract.

contract Bookstore {
    address public owner;
    uint256 public nextBookId;

    struct Book {
        string title;
        string author;
        string publication;
        bool available;
    }

    mapping(uint256 => Book) public books;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
        nextBookId = 1;
    }
    // This function should only be accessible by Gavin (owner).
    // Using this function, he can add a book by specifying the title, author, and publication of the book respectively.
    // The book should automatically get an ID of type uint assigned to it in the smart contract.
    // The ID of the newly added book should be one greater than the ID of the previously added book, or 1 if no books have been added yet.

    function addBook(string memory title, string memory author, string memory publication) public onlyOwner {
        books[nextBookId] = Book(title, author, publication, true);
        nextBookId++;
    }

    // This function should only be accessible by Gavin (owner).
    // Using this function, Gavin can make a book unavailable in cases like the book being sold, the book getting damaged, etc.
    function removeBook(uint256 id) public onlyOwner {
        require(bytes(books[id].title).length != 0, "Book does not exist");
        books[id].available = false;
    }

    // This function should only be accessible by Gavin (owner).
    // Using this function, Gavin can modify the details of a book whose ID is id.
    // If there is no book with ID id in the database, the transaction must fail.
    // ( Check the explanation of getDetailsById() function below for better understanding).
    // The smart contract can have a boolean indicating the availability of a book.
    // This boolean value should be true if the book is available and false if the book is not available.
    function updateDetails(
        uint256 id,
        string memory title,
        string memory author,
        string memory publication,
        bool available
    ) public onlyOwner {
        require(bytes(books[id].title).length != 0, "Book does not exist");
        books[id] = Book(title, author, publication, available);
    }

    function findBookByTitle(string memory title) public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](nextBookId - 1);
        uint256 count = 0;
        for (uint256 i = 1; i < nextBookId; i++) {
            if (keccak256(abi.encodePacked(books[i].title)) == keccak256(abi.encodePacked(title))) {
                if (msg.sender == owner || books[i].available) {
                    result[count] = i;
                    count++;
                }
            }
        }
        uint256[] memory trimmedResult = new uint256[](count);
        for (uint256 j = 0; j < count; j++) {
            trimmedResult[j] = result[j];
        }
        return trimmedResult;
    }

    function findAllBooksOfPublication(string memory publication) public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](nextBookId - 1);
        uint256 count = 0;
        for (uint256 i = 1; i < nextBookId; i++) {
            if (keccak256(abi.encodePacked(books[i].publication)) == keccak256(abi.encodePacked(publication))) {
                if (msg.sender == owner || books[i].available) {
                    result[count] = i;
                    count++;
                }
            }
        }
        uint256[] memory trimmedResult = new uint256[](count);
        for (uint256 j = 0; j < count; j++) {
            trimmedResult[j] = result[j];
        }
        return trimmedResult;
    }

    function findAllBooksOfAuthor(string memory author) public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](nextBookId - 1);
        uint256 count = 0;
        for (uint256 i = 1; i < nextBookId; i++) {
            if (keccak256(abi.encodePacked(books[i].author)) == keccak256(abi.encodePacked(author))) {
                if (msg.sender == owner || books[i].available) {
                    result[count] = i;
                    count++;
                }
            }
        }
        uint256[] memory trimmedResult = new uint256[](count);
        for (uint256 j = 0; j < count; j++) {
            trimmedResult[j] = result[j];
        }
        return trimmedResult;
    }

    function getDetailsById(uint256 id) public view returns (string memory, string memory, string memory, bool) {
        require(bytes(books[id].title).length != 0, "Book does not exist");
        if (msg.sender != owner) {
            require(books[id].available, "Book is not available");
        }
        Book memory book = books[id];
        return (book.title, book.author, book.publication, book.available);
    }
}
