// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract Exchange is ERC20 {
    using SafeMath for uint256;

    IERC20 public token;
    uint256 public tokenReserve;
    uint256 public ethReserve;

    constructor(address _token) ERC20("Liquidity Provider Token", "LPT") {
        require(_token != address(0), "Invalid token address");
        token = IERC20(_token);
    }

    function addLiquidity(uint256 amountOfToken) public payable returns (uint256) {
        if (ethReserve == 0) {
            token.transferFrom(msg.sender, address(this), amountOfToken);
            uint256 liquidity = msg.value;
            _mint(msg.sender, liquidity);
            ethReserve = msg.value;
            tokenReserve = amountOfToken;
            return liquidity;
        } else {
            uint256 tokenAmount = (msg.value.mul(tokenReserve)).div(ethReserve);
            require(amountOfToken >= tokenAmount, "Insufficient token amount");
            token.transferFrom(msg.sender, address(this), tokenAmount);
            uint256 liquidity = (totalSupply().mul(msg.value)).div(ethReserve);
            _mint(msg.sender, liquidity);
            ethReserve = ethReserve.add(msg.value);
            tokenReserve = tokenReserve.add(tokenAmount);
            return liquidity;
        }
    }

    function removeLiquidity(uint256 amountOfLPTokens) public returns (uint256, uint256) {
        uint256 ethAmount = (ethReserve.mul(amountOfLPTokens)).div(totalSupply());
        uint256 tokenAmount = (tokenReserve.mul(amountOfLPTokens)).div(totalSupply());
        _burn(msg.sender, amountOfLPTokens);
        payable(msg.sender).transfer(ethAmount);
        token.transfer(msg.sender, tokenAmount);
        ethReserve = ethReserve.sub(ethAmount);
        tokenReserve = tokenReserve.sub(tokenAmount);
        return (ethAmount, tokenAmount);
    }

    function ethToTokenSwap() external payable {
        uint256 tokenAmount = getAmountOut(msg.value, ethReserve, tokenReserve);
        ethReserve = ethReserve.add(msg.value);
        tokenReserve = tokenReserve.sub(tokenAmount);
        token.transfer(msg.sender, tokenAmount);
    }

    function tokenToEthSwap(uint256 tokensToSwap) public {
        uint256 ethAmount = getAmountOut(tokensToSwap, tokenReserve, ethReserve);
        token.transferFrom(msg.sender, address(this), tokensToSwap);
        ethReserve = ethReserve.sub(ethAmount);
        tokenReserve = tokenReserve.add(tokensToSwap);
        payable(msg.sender).transfer(ethAmount);
    }

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256) {
        uint256 amountInWithFee = amountIn.mul(99).div(100);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.add(amountInWithFee);
        return numerator.div(denominator);
    }

    function getLPTokensToMint() public view returns (uint256) {
        return (totalSupply().mul(msg.value)).div(ethReserve);
    }

    function getEthAndTokenToReturn() public view returns (uint256, uint256) {
        uint256 ethAmount = (ethReserve.mul(msg.value)).div(totalSupply());
        uint256 tokenAmount = (tokenReserve.mul(msg.value)).div(totalSupply());
        return (ethAmount, tokenAmount);
    }

    function getReserve() public view returns (uint256) {
        return tokenReserve;
    }

    function getBalance(address user) public view returns (uint256) {
        return balanceOf(user);
    }
}
