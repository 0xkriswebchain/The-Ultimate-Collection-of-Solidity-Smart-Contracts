// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title YieldFarming
 * @dev A contract for yield farming with multiple pools and reward distribution.
 */
contract YieldFarming is ERC20 {
    struct Pool {
        uint256 maxAmount; // Maximum amount that can be deposited in the pool
        uint256 yieldPercent; // Yield percentage for the pool
        uint256 minDeposit; // Minimum deposit required for the pool
        uint256 rewardTime; // Time interval for reward calculation
        uint256 totalDeposits; // Total deposits in the pool
    }

    struct User {
        uint256 totalDeposits; // Total deposits made by the user
        uint256 claimableRewards; // Rewards that can be claimed by the user
        mapping(uint256 => uint256) deposits; // Mapping of poolId to deposit amount
        mapping(uint256 => uint256) lastClaimTime; // Mapping of poolId to last claim time
    }

    mapping(uint256 => Pool) public pools; // Mapping of poolId to Pool
    mapping(address => User) public users; // Mapping of user address to User
    address[] public whaleWallets; // List of whale wallets
    uint256 public poolCount; // Total number of pools

    /**
     * @dev Constructor that initializes the ERC20 token.
     */
    constructor() ERC20("YieldToken", "YLD") {}

    /**
     * @dev Adds a new pool.
     * @param maxAmount Maximum amount that can be deposited in the pool.
     * @param yieldPercent Yield percentage for the pool.
     * @param minDeposit Minimum deposit required for the pool.
     * @param rewardTime Time interval for reward calculation.
     */
    function addPool(uint256 maxAmount, uint256 yieldPercent, uint256 minDeposit, uint256 rewardTime) public {
        pools[poolCount] = Pool(maxAmount, yieldPercent, minDeposit, rewardTime, 0);
        poolCount++;
    }

    /**
     * @dev Deposits Wei into a specific pool.
     * @param poolId The ID of the pool to deposit into.
     */
    function depositWei(uint256 poolId) public payable {
        Pool storage pool = pools[poolId];
        require(pool.maxAmount > 0, "Pool does not exist");
        require(msg.value >= pool.minDeposit, "Deposit less than minimum");
        require(users[msg.sender].deposits[poolId] == 0, "Already deposited in this pool");

        pool.totalDeposits += msg.value;
        users[msg.sender].deposits[poolId] = msg.value;
        users[msg.sender].lastClaimTime[poolId] = block.timestamp;
        users[msg.sender].totalDeposits += msg.value;

        if (users[msg.sender].totalDeposits > 10000 && !isWhale(msg.sender)) {
            whaleWallets.push(msg.sender);
        }
    }

    /**
     * @dev Withdraws Wei from a specific pool.
     * @param poolId The ID of the pool to withdraw from.
     * @param amount The amount to withdraw.
     */
    function withdrawWei(uint256 poolId, uint256 amount) public {
        User storage user = users[msg.sender];
        require(user.deposits[poolId] >= amount, "Insufficient deposit");

        claimRewards(poolId);

        user.deposits[poolId] -= amount;
        user.totalDeposits -= amount;
        pools[poolId].totalDeposits -= amount;

        if (user.deposits[poolId] == 0) {
            user.claimableRewards = 0;
        }

        payable(msg.sender).transfer(amount);
    }

    /**
     * @dev Claims rewards for a specific pool.
     * @param poolId The ID of the pool to claim rewards from.
     */
    function claimRewards(uint256 poolId) public {
        User storage user = users[msg.sender];
        Pool storage pool = pools[poolId];
        require(user.deposits[poolId] > 0, "No deposits in this pool");

        uint256 timeElapsed = block.timestamp - user.lastClaimTime[poolId];
        uint256 reward = (user.deposits[poolId] * pool.yieldPercent * timeElapsed) / (pool.rewardTime * 100);

        if (user.totalDeposits > 10000) {
            reward = reward * 120 / 100; // 20% extra for whale wallets
        }

        user.claimableRewards += reward;
        user.lastClaimTime[poolId] = block.timestamp;

        _mint(msg.sender, reward);
    }

    /**
     * @dev Returns the details of a specific pool.
     * @param poolId The ID of the pool to check.
     * @return maxAmount, yieldPercent, minDeposit, rewardTime
     */
    function checkPoolDetails(uint256 poolId) public view returns (uint256, uint256, uint256, uint256) {
        Pool storage pool = pools[poolId];
        return (pool.maxAmount, pool.yieldPercent, pool.minDeposit, pool.rewardTime);
    }

    /**
     * @dev Returns the total deposits and claimable rewards of a user.
     * @param user The address of the user to check.
     * @return totalDeposits, claimableRewards
     */
    function checkUserDeposits(address user) public view returns (uint256, uint256) {
        User storage u = users[user];
        return (u.totalDeposits, u.claimableRewards);
    }

    /**
     * @dev Returns the addresses and deposit amounts of users in a specific pool.
     * @param poolId The ID of the pool to check.
     * @return addresses, amounts
     */
    function checkUserDepositInPool(uint256 poolId) public view returns (address[] memory, uint256[] memory) {
        address[] memory addresses = new address[](poolCount);
        uint256[] memory amounts = new uint256[](poolCount);
        uint256 count = 0;

        for (uint256 i = 0; i < poolCount; i++) {
            if (users[addresses[i]].deposits[poolId] > 0) {
                addresses[count] = addresses[i];
                amounts[count] = users[addresses[i]].deposits[poolId];
                count++;
            }
        }

        return (addresses, amounts);
    }

    /**
     * @dev Returns the claimable rewards for a specific pool.
     * @param poolId The ID of the pool to check.
     * @return reward
     */
    function checkClaimableRewards(uint256 poolId) public view returns (uint256) {
        User storage user = users[msg.sender];
        Pool storage pool = pools[poolId];
        uint256 timeElapsed = block.timestamp - user.lastClaimTime[poolId];
        uint256 reward = (user.deposits[poolId] * pool.yieldPercent * timeElapsed) / (pool.rewardTime * 100);

        if (user.totalDeposits > 10000) {
            reward = reward * 120 / 100; // 20% extra for whale wallets
        }

        return reward;
    }

    /**
     * @dev Returns the remaining capacity of a specific pool.
     * @param poolId The ID of the pool to check.
     * @return remainingCapacity
     */
    function checkRemainingCapacity(uint256 poolId) public view returns (uint256) {
        Pool storage pool = pools[poolId];
        return pool.maxAmount - pool.totalDeposits;
    }

    /**
     * @dev Returns the list of whale wallets.
     * @return whaleWallets
     */
    function checkWhaleWallets() public view returns (address[] memory) {
        return whaleWallets;
    }

    /**
     * @dev Checks if a user is a whale.
     * @param user The address of the user to check.
     * @return isWhale
     */
    function isWhale(address user) internal view returns (bool) {
        for (uint256 i = 0; i < whaleWallets.length; i++) {
            if (whaleWallets[i] == user) {
                return true;
            }
        }
        return false;
    }
}
