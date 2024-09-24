// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// A shipment service is having trouble tracking orders, which is causing issues for customers.
// To make things better, they are moving their database to a smart contract-based blockchain solution.
// This will make the process more transparent and efficient, and help with order management.

// Process:

// 1. The smart contract will be deployed by the warehouse manager, who will act as the owner of the contract.
// 2. The owner, having access to the list of orders placed, will utilize the smart contract to mark an order as dispatched and initiate the shipping process through the shipping service.
// 3. While marking an order as dispatched in the smart contract, the owner will also enter a four-digit OTP (One-Time Password). The OTP can be any number between 999 and 10,000 (excluding those starting with 0).
// 4. Through some messaging service, the customer who is supposed to receive the order will be provided with the OTP. The customer will need to send the OTP to the smart contract to confirm the acceptance of the order upon its arrival at their address.
// 5. Using the smart contract, customers will be able to check the status of their orders. The possible order statuses are as follows:
// "no orders placed" if the customer has not placed any orders.
// "shipped" if the order has been dispatched.
// "delivered" if the last order has been successfully delivered.
// 6. It is important to note that the owner's address cannot be considered a customer's address to maintain proper functionality and differentiation within the smart contract.
// 7. For ease of implementation, in this phase of migration, until one order is completely delivered, another order cannot be dispatched to the same address.

contract ShipmentService {
    address public owner;
    mapping(address => uint256) private pins;
    mapping(address => string) private statuses;
    mapping(address => uint256) private completedDeliveries;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier onlyCustomer(address customerAddress) {
        require(msg.sender == customerAddress, "Only the customer can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // This function can only be accessed by the owner (warehouse manager) and is used to mark an order as dispatched.
    // The owner provides the customer's address and a four-digit OTP (pin) between 999 and 10,000 to verify the order.
    function shipWithPin(address customerAddress, uint256 pin) public onlyOwner {
        require(pin >= 1000 && pin <= 9999, "PIN must be a four-digit number between 1000 and 9999");
        require(customerAddress != owner, "Owner cannot be a customer");
        require(
            keccak256(abi.encodePacked(statuses[customerAddress])) != keccak256(abi.encodePacked("shipped")),
            "Previous order not yet delivered"
        );

        pins[customerAddress] = pin;
        statuses[customerAddress] = "shipped";
    }

    // acceptOrder(uint pin) public returns (): This function can only be accessed by the customer.
    // After receiving the shipment at their address, the customer can mark the order as accepted
    // by entering the OTP (pin) provided to them
    function acceptOrder(uint256 pin) public {
        require(pins[msg.sender] == pin, "Invalid PIN");
        require(
            keccak256(abi.encodePacked(statuses[msg.sender])) == keccak256(abi.encodePacked("shipped")),
            "No order to accept"
        );

        statuses[msg.sender] = "delivered";
        completedDeliveries[msg.sender] += 1;
        pins[msg.sender] = 0; // Reset the pin
    }

    // checkStatus(address customerAddress) public returns (string):
    // This function allows customers to check the status of their own orders by providing their address.
    // It returns a string indicating the status of the order. Possible status values include:

    // "no orders placed" if the customer has not placed any orders.
    // "shipped" if the order has been dispatched.
    // "delivered" if the last order has been successfully delivered.

    function checkStatus(address customerAddress) public view returns (string memory) {
        if (keccak256(abi.encodePacked(statuses[customerAddress])) == keccak256(abi.encodePacked(""))) {
            return "no orders placed";
        }
        return statuses[customerAddress];
    }

    // totalCompletedDeliveries(address customerAddress) public returns (uint):
    // This function enables customers to determine the number of successfully completed deliveries to their specific address.
    // By providing their address, customers can retrieve the total count of completed deliveries.
    // The owner can also use this function to check the number of successfully completed deliveries for any address.
    function totalCompletedDeliveries(address customerAddress) public view returns (uint256) {
        return completedDeliveries[customerAddress];
    }
}
