// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleBookRental {

    struct Book {
        string title;
        uint256 rentalPrice; // in wei
        address currentOwner;
        bool isAvailable;
    }

    mapping(uint256 => Book) public books;
    uint256 public bookCount;

    event BookListed(uint256 indexed bookId, string title, uint256 rentalPrice);
    event BookRented(uint256 indexed bookId, address indexed renter);

    modifier onlyOwner(uint256 bookId) {
        require(msg.sender == books[bookId].currentOwner, "You are not the owner of this book");
        _;
    }

    modifier isAvailable(uint256 bookId) {
        require(books[bookId].isAvailable, "Book is not available for rent");
        _;
    }

    constructor() {
        bookCount = 0;
    }

    // Function to list a book for rent
    function listBook(string memory title, uint256 rentalPrice) public {
        require(rentalPrice > 0, "Rental price must be greater than 0");
        
        uint256 bookId = bookCount++;
        books[bookId] = Book({
            title: title,
            rentalPrice: rentalPrice,
            currentOwner: msg.sender,
            isAvailable: true
        });

        emit BookListed(bookId, title, rentalPrice);
    }

    // Function to rent a book
    function rentBook(uint256 bookId) public payable isAvailable(bookId) {
        Book storage book = books[bookId];
        require(msg.value == book.rentalPrice, "Incorrect rental price");

        // Transfer the rental fee to the owner
        payable(book.currentOwner).transfer(msg.value);

        // Mark the book as rented
        book.isAvailable = false;

        emit BookRented(bookId, msg.sender);
    }
}
