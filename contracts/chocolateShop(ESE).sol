// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";

contract ChocolateShop {
    using SafeMath for uint256;

    uint256 public chocolatesInBag;

    function buyChocolates(uint256 n) public {
        require(n > 0, "Buy more chocolates");
        chocolatesInBag = chocolatesInBag.tryAdd(n);
    }

    function sellChocolates(uint256 n) public {
        require(n > 0, "Sell more chocolates");
        chocolatesInBag = chocolatesInBag.trySub(n);
    }

    function getChocolatesInBag() public view returns (uint256) {
        return chocolatesInBag;
    }
}
