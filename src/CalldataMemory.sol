// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract CalldataMemory {
    // 391 gas
    function argAsCalldata(string calldata name) external pure {}

    // 515 gas
    function argAsMemory(string memory name) external pure {}
}
