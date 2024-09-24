// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TicketBooking {
    uint256 constant TOTAL_SEATS = 20;
    uint256[] private availableSeats;
    mapping(uint256 => bool) private seatBooked;
    mapping(address => uint256[]) private userBookings;

    constructor() {
        for (uint256 i = 1; i <= TOTAL_SEATS; i++) {
            availableSeats.push(i);
            seatBooked[i] = false;
        }
    }

    function bookSeats(uint256[] memory seatNumbers) public {
        require(seatNumbers.length > 0 && seatNumbers.length <= 4, "Invalid number of seats");
        require(userBookings[msg.sender].length + seatNumbers.length <= 4, "Cannot book more than 4 seats");

        // Check for duplicates in the input array
        for (uint256 i = 0; i < seatNumbers.length; i++) {
            for (uint256 j = i + 1; j < seatNumbers.length; j++) {
                require(seatNumbers[i] != seatNumbers[j], "Duplicate seat number in input");
            }
        }

        // Check if all seats are available
        for (uint256 i = 0; i < seatNumbers.length; i++) {
            require(seatNumbers[i] > 0 && seatNumbers[i] <= TOTAL_SEATS, "Invalid seat number");
            require(!seatBooked[seatNumbers[i]], "Seat already booked");
        }

        // Book the seats
        for (uint256 i = 0; i < seatNumbers.length; i++) {
            seatBooked[seatNumbers[i]] = true;
            userBookings[msg.sender].push(seatNumbers[i]);
            // Remove the booked seat from availableSeats
            for (uint256 j = 0; j < availableSeats.length; j++) {
                if (availableSeats[j] == seatNumbers[i]) {
                    availableSeats[j] = availableSeats[availableSeats.length - 1];
                    availableSeats.pop();
                    break;
                }
            }
        }
    }

    function showAvailableSeats() public view returns (uint256[] memory) {
        return availableSeats;
    }

    function checkAvailability(uint256 seatNumber) public view returns (bool) {
        require(seatNumber > 0 && seatNumber <= TOTAL_SEATS, "Invalid seat number");
        return !seatBooked[seatNumber];
    }

    function myTickets() public view returns (uint256[] memory) {
        return userBookings[msg.sender];
    }
}
