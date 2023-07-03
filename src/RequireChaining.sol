// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract RequireChaining {
    address owner = msg.sender;

    // 2279 gas
    function requireChained() external payable {
        require(msg.sender == owner);
        require(msg.value == 0);
        require(block.timestamp < 1000_000);
    }

    // 2317 gas
    function requireNotChained() external payable {
        require(msg.sender == owner && msg.value == 0 && block.timestamp < 1000_000);
    }
}
