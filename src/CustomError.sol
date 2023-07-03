// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

error OnlyOwner();

// Deployment cost: 47410 gas
contract CustomError {
    address owner = msg.sender;

    // 2303 gas
    function setOwner() public {
        if (msg.sender != owner) revert OnlyOwner();

        owner = msg.sender;
    }
}

// Deployment cost: 60222 gas
contract RequireError {
    address owner = msg.sender;

    // 2381 gas
    function setOwner() public {
        require(msg.sender == owner, "Only owner can call this function");

        owner = msg.sender;
    }
}
