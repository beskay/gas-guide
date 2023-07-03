// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract BitShift {
    // 241 gas
    // 153 gas (--via-ir enabled)
    function divide(uint256 a) external pure returns (uint256) {
        return a >> 2; // divide by 2^2 = 4
    }
}

contract NoBitShift {
    // 317 gas
    // 153 gas (--via-ir enabled)
    function divide(uint256 a) external pure returns (uint256) {
        return a / 4;
    }
}
