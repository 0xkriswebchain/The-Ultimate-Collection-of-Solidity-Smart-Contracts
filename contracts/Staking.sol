// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staking {
    IERC20 public token;
    address public owner;
    uint256 public totalStaked;

    struct Stake {
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => Stake) public stakes;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor(address _token) {
        token = IERC20(_token);
        owner = msg.sender;
    }

    function stake(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");

        Stake storage userStake = stakes[msg.sender];

        if (userStake.amount > 0) {
            uint256 interest = getAccruedInterest(msg.sender);
            if (interest > 0) {
                token.transfer(msg.sender, interest);
            }
        }

        token.transferFrom(msg.sender, address(this), amount);
        userStake.amount += amount;
        userStake.timestamp = block.timestamp;
        totalStaked += amount;
    }

    function redeem(uint256 amount) public {
        Stake storage userStake = stakes[msg.sender];
        require(amount > 0, "Amount must be greater than 0");
        require(userStake.amount >= amount, "Insufficient staked amount");

        userStake.amount -= amount;
        totalStaked -= amount;
        token.transfer(msg.sender, amount);
    }

    function claimInterest() public {
        uint256 interest = getAccruedInterest(msg.sender);
        require(interest > 0, "No interest due");

        stakes[msg.sender].timestamp = block.timestamp;
        token.transfer(msg.sender, interest);
    }

    function getAccruedInterest(address user) public view returns (uint256) {
        Stake storage userStake = stakes[user];
        if (userStake.amount == 0) {
            return 0;
        }

        uint256 stakedTime = block.timestamp - userStake.timestamp;
        uint256 interestRate;

        if (stakedTime >= 30 days) {
            interestRate = 50;
        } else if (stakedTime >= 7 days) {
            interestRate = 10;
        } else if (stakedTime >= 1 days) {
            interestRate = 1;
        } else {
            return 0;
        }

        return (userStake.amount * interestRate) / 100;
    }

    function sweep() public onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        token.transfer(owner, balance);
    }
}
