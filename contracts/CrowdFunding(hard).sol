// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CrowdFund {
    IERC20 public token;
    uint256 public campaignCount;

    struct Campaign {
        address creator;
        uint256 goal;
        uint256 duration;
        uint256 startTime;
        uint256 totalFunds;
        bool withdrawn;
    }

    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => mapping(address => uint256)) public contributions;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function createCampaign(uint256 _goal, uint256 _duration) external {
        campaignCount++;
        campaigns[campaignCount] = Campaign({
            creator: msg.sender,
            goal: _goal,
            duration: _duration,
            startTime: block.timestamp,
            totalFunds: 0,
            withdrawn: false
        });
    }

    function contribute(uint256 _id, uint256 _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.creator != address(0), "Campaign does not exist");
        require(msg.sender != campaign.creator, "Creator cannot contribute");
        require(block.timestamp < campaign.startTime + campaign.duration, "Campaign has ended");

        token.transferFrom(msg.sender, address(this), _amount);
        contributions[_id][msg.sender] += _amount;
        campaign.totalFunds += _amount;
    }

    function cancelContribution(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.creator != address(0), "Campaign does not exist");
        require(block.timestamp < campaign.startTime + campaign.duration, "Campaign has ended");

        uint256 contribution = contributions[_id][msg.sender];
        require(contribution > 0, "No contributions to cancel");

        contributions[_id][msg.sender] = 0;
        campaign.totalFunds -= contribution;
        token.transfer(msg.sender, contribution);
    }

    function withdrawFunds(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.creator != address(0), "Campaign does not exist");
        require(msg.sender == campaign.creator, "Only creator can withdraw");
        require(block.timestamp >= campaign.startTime + campaign.duration, "Campaign is still active");
        require(campaign.totalFunds >= campaign.goal, "Goal not reached");
        require(!campaign.withdrawn, "Funds already withdrawn");

        campaign.withdrawn = true;
        token.transfer(campaign.creator, campaign.totalFunds);
    }

    function refund(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.creator != address(0), "Campaign does not exist");
        require(block.timestamp >= campaign.startTime + campaign.duration, "Campaign is still active");
        require(campaign.totalFunds < campaign.goal, "Goal was reached");

        uint256 contribution = contributions[_id][msg.sender];
        require(contribution > 0, "No contributions to refund");

        contributions[_id][msg.sender] = 0;
        token.transfer(msg.sender, contribution);
    }

    function getContribution(uint256 _id, address _contributor) public view returns (uint256) {
        return contributions[_id][_contributor];
    }

    function getCampaign(uint256 _id) external view returns (uint256 remainingTime, uint256 goal, uint256 totalFunds) {
        Campaign storage campaign = campaigns[_id];
        require(campaign.creator != address(0), "Campaign does not exist");

        remainingTime = (block.timestamp >= campaign.startTime + campaign.duration)
            ? 0
            : (campaign.startTime + campaign.duration - block.timestamp);
        goal = campaign.goal;
        totalFunds = campaign.totalFunds;
    }
}
