// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

// Deployment cost: 53416 gas
contract RevertShort {
    address owner = msg.sender;

    // 2363 gas
    function setOwner() external {
        require(msg.sender == owner, "!owner");
        
        owner = msg.sender;
    }
}

// Deployment cost: 60222 gas
contract RevertLong {
    address owner = msg.sender;

    // 2381 gas
    function setOwner() external {
        require(msg.sender == owner, "Only the contract owner can call this function!");
        
        owner = msg.sender;
    }
}