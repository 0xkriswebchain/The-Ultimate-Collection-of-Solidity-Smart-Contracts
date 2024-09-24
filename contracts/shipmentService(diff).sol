// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ShipmentService {
    address public owner;

    struct Order {
        uint256 pin;
        bool isDelivered;
    }

    mapping(address => Order[]) public orders;
    mapping(address => uint256) public completedDeliveries;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyCustomer(address customerAddress) {
        require(msg.sender == customerAddress, "Only customer can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function shipWithPin(address customerAddress, uint256 pin) public onlyOwner {
        require(pin >= 1000 && pin <= 9999, "Pin must be a four-digit number between 1000 and 9999");
        orders[customerAddress].push(Order(pin, false));
    }

    function acceptOrder(uint256 pin) public {
        Order[] storage customerOrders = orders[msg.sender];
        for (uint256 i = 0; i < customerOrders.length; i++) {
            if (customerOrders[i].pin == pin && !customerOrders[i].isDelivered) {
                customerOrders[i].isDelivered = true;
                completedDeliveries[msg.sender]++;
                return;
            }
        }
        revert("Invalid pin or order already delivered");
    }

    function checkStatus(address customerAddress) public view onlyCustomer(customerAddress) returns (uint256) {
        Order[] storage customerOrders = orders[customerAddress];
        uint256 pendingOrders = 0;
        for (uint256 i = 0; i < customerOrders.length; i++) {
            if (!customerOrders[i].isDelivered) {
                pendingOrders++;
            }
        }
        return pendingOrders;
    }

    function totalCompletedDeliveries(address customerAddress) public view returns (uint256) {
        return completedDeliveries[customerAddress];
    }
}
