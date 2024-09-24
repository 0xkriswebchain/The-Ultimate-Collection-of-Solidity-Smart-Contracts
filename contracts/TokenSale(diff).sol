// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract TokenSale {
    uint256 public totalSupply;
    uint256 public tokenPrice;
    uint256 public saleDuration;
    uint256 public saleEndTime;
    uint256 public totalSold;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public lastPurchaseTime;
    mapping(address => uint256) public lastSellTime;
    mapping(address => uint256) public referralCount;
    mapping(address => uint256) public referralRewards;

    constructor(uint256 _totalSupply, uint256 _tokenPrice, uint256 _saleDuration) {
        totalSupply = _totalSupply;
        tokenPrice = _tokenPrice;
        saleDuration = _saleDuration;
        saleEndTime = block.timestamp + saleDuration;
    }

    function checkTokenPrice() public view returns (uint256) {
        return tokenPrice;
    }

    function purchaseToken(address referrer) public payable {
        require(block.timestamp < saleEndTime, "Token sale has ended");
        require(balances[msg.sender] == 0, "Address has already purchased tokens");
        require(msg.value >= tokenPrice, "Insufficient funds to purchase tokens");
        require(referrer != address(0) && referrer != msg.sender, "Invalid referrer address");

        uint256 tokensToPurchase = msg.value / tokenPrice;
        require(totalSold + tokensToPurchase <= totalSupply, "Not enough tokens available for purchase");

        balances[msg.sender] += tokensToPurchase;
        totalSold += tokensToPurchase;
        lastPurchaseTime[msg.sender] = block.timestamp;

        // Referral system
        uint256 referralBonus = getReferralBonus(referrer);
        if (referralBonus > 0) {
            uint256 referralTokens = (tokensToPurchase * referralBonus) / 100;
            require(totalSold + referralTokens <= totalSupply, "Not enough tokens available for referral");
            balances[referrer] += referralTokens;
            referralRewards[referrer] += referralTokens;
            referralCount[referrer]++;
            totalSold += referralTokens;
        }

        // Adjust token price
        adjustTokenPrice(tokensToPurchase, true);
    }

    function sellTokenBack(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient token balance");
        uint256 maxSellAmount = (balances[msg.sender] * 20) / 100;
        require(amount <= maxSellAmount, "Cannot sell more than 20% of purchased tokens in a week");
        require(block.timestamp >= lastSellTime[msg.sender] + 1 weeks, "Can only sell tokens once a week");

        uint256 weiAmount = amount * tokenPrice;
        balances[msg.sender] -= amount;
        lastSellTime[msg.sender] = block.timestamp;
        payable(msg.sender).transfer(weiAmount);

        // Adjust token price
        adjustTokenPrice(amount, false);
    }

    function checkTokenBalance(address buyer) public view returns (uint256) {
        return balances[buyer];
    }

    function saleTimeLeft() public view returns (uint256) {
        require(block.timestamp < saleEndTime, "Token sale has ended");
        return saleEndTime - block.timestamp;
    }

    function getReferralCount(address referrer) public view returns (uint256) {
        return referralCount[referrer];
    }

    function getReferralRewards(address referrer) public view returns (uint256) {
        return referralRewards[referrer];
    }

    function getReferralBonus(address referrer) internal view returns (uint256) {
        uint256 count = referralCount[referrer];
        if (count == 0) return 5;
        if (count == 1) return 4;
        if (count == 2) return 3;
        if (count == 3) return 2;
        if (count == 4) return 1;
        return 0;
    }

    function adjustTokenPrice(uint256 tokens, bool isPurchase) internal {
        uint256 percentage = (tokens * 100) / totalSupply;
        uint256 adjustment = (percentage * tokenPrice) / 100;
        if (isPurchase) {
            tokenPrice += adjustment / 2;
        } else {
            tokenPrice -= adjustment;
        }
    }
}
