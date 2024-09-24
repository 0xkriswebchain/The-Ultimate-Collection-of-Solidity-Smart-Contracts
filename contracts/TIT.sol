// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract TrianglePossibility {
    function checkTriangle(uint256 _a, uint256 _b, uint256 _c) public pure returns (bool) {
        if ((_a + _b > _c) && (_b + _c > _a) && (_a + _c > _b)) {
            return true;
        } else {
            return false;
        }
        // return (_a + _b > _c) && (_a + _c > _b) && (_b + _c > _a);
    }
}
