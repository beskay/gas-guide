// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
Generated with slither src/StoragePacking.sol --print variable-order
+----------------------+-----------------------------+------+--------+
|         Name         |             Type            | Slot | Offset |
+----------------------+-----------------------------+------+--------+
|   StorageLayout.a    |           uint256           |  0   |   0    |
|   StorageLayout.b    |          uint256[2]         |  1   |   0    |
|   StorageLayout.c    |          uint128[2]         |  3   |   0    |
|   StorageLayout.d    |             bool            |  4   |   0    |
|   StorageLayout.e    |           address           |  4   |   1    |
| StorageLayout.choice | StorageLayout.ActionChoices |  4   |   21   |
|   StorageLayout.f    |     StorageLayout.Entry     |  5   |   0    |
|   StorageLayout.g    |    StorageLayout.Entry[]    |  6   |   0    |
|   StorageLayout.h    | mapping(uint256 => uint256) |  7   |   0    |
|   StorageLayout.i    | mapping(uint256 => uint256) |  8   |   0    |
+----------------------+-----------------------------+------+--------+ 
*/

contract StorageLayout {
    uint256 a; // slot 0
    uint256[2] b; // slots 1-2

    // array data can be packed too
    uint128[2] c; // slot 3

    bool d; // slot 4
    address e; // slot 4, offset 1 byte (size of bool is 1 byte)

    // enums are uint8 by default (if they have less than 256 elements)
    enum ActionChoices {
        GoLeft,
        GoRight,
        GoStraight,
        SitStill
    }

    ActionChoices choice; // slot 4, offset 21 byte (1 byte for bool + 20 bytes for address)

    struct Entry {
        uint128 id;
        uint128 value;
    }

    Entry f; // slot 5
    Entry[] g; // slot 6 for length, keccak256(6)+ for data

    mapping(uint256 => uint256) h; // slot 7, data at slot(key * 7)
    mapping(uint256 => uint256) i; // slot 8, data at slot(key * 8)
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
        // We are storing two variables, but only pay for a single SSTORE
        f = Entry(1, 2);
    }

    // Execution cost: 2518 gas
    function readStruct() external view returns (Entry memory) {
        // We are reading two storage vars, but only pay for a single SLOAD
        return f;
    }
}
