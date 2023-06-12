// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract StorageLayout {
    uint256 a; // slot 0
    uint256[2] b; // slots 1-2

    // arrays can be packed too
    uint128[2] c; // slot 3

    struct Entry {
        uint128 id;
        uint128 value;
    }

    Entry d; // slot 4
    Entry[] e; // slot 5 for length, keccak256(5)+ for data

    mapping(uint256 => uint256) f; // slot 6, data at slot(key * 6)
    mapping(uint256 => uint256) g; // slot 7, data at slot(key * 7)
}

contract StoragePacking is StorageLayout {
    // Execution cost: 22306 gas
    function writeUint256() external {
        ++b[0];
    }

    // Execution cost: 22557 gas
    function writeUint128() external {
        // Writing to a single reduced size var is more expensive than writing to a uint256,
        // because the EVM always operates on 32 bytes.
        ++c[0];
    }

    // Execution cost: 22323 gas
    function writeStruct() external {
        // We are writing to storage vars, but only pay for a single SSTORE
        d = Entry(1, 2);
    }

    // Execution cost: 2518 gas
    function readStruct() external view returns (Entry memory) {
        // We are reading two storage vars, but only pay for a single SLOAD
        return d;
    }
}
