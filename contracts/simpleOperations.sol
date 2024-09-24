// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleOperations {
    event BitRetrieved(uint256 num, uint256 position, uint8 bit);

    function calculateAverage(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 c = (a + b) / 2;
        return c;
    }

    /**
     * @notice getBit returns the bit at the given position
     * @param num the number to get the bit from
     * @param _position the position of the bit to get
     * @return bit the bit at the given position
     */
    function getBit(uint256 num, uint256 _position) public returns (uint8 bit) {
        require(_position > 0, "Position must be greater than zero");
        require(_position <= 256, "Position must be within the range of the bit length of uint256");
        uint256 shifted = num >> (_position - 1);
        bit = uint8(shifted & 1);
        emit BitRetrieved(num, _position, bit);
    }

    /**
     * @notice sendEth sends ETH to the given address
     * @param to the address to send ETH to
     */
    function sendEth(address to) public payable {
        require(to != msg.sender, "Cannot send ETH to the sender");
        (bool success,) = to.call{value: msg.value}("");
        // (bool success, bytes memory data) = targetAddress.call{value: amount, gas: gasLimit}(encodedFunctionCall);
        require(success, "Failed to send ETH");
    }
}
