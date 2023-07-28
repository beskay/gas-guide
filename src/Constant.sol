// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract Constant {
    // 4 bytes, will be replaced with `PUSH4(0xaabbccdd)`
    bytes32 constant b = bytes32(hex"AABBCCDD");
    string constant d = "test";

    // 152 gas
    function readConstant() public pure returns (bytes32) {
        return b;
    }
}

contract Immutable {
    // size(address) = 20 bytes, but 32 bytes are reserverd for immutable variables
    // compiler will replace `a` with `PUSH32(address)`
    address immutable a;

    constructor() {
        // declare immutable variables in constructor
        a = address(0x1234567890123456789012345678901234567890);
    }

    // 167 gas
    function readImmutable() public view returns (address) {
        return a;
    }
}

contract Mutable {
    uint256 c;

    // 2246 gas (COLD SLOAD)
    function readMutable() public view returns (uint256) {
        return c;
    }
}
