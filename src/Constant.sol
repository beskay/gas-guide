// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract Constant {
    // size(address) = 20 bytes, but 32 bytes are reserverd for immutable variables
    // compiler will replace `a` with `PUSH32(address)`
    address immutable a;
    
    // 4 bytes, will be replaced with `PUSH4(0xaabbccdd)`
    bytes32 constant b = bytes32(hex"AABBCCDD");
    
    uint256 c;

    string constant d = "test";

    constructor() {
        // declare immutable variables in constructor
        a = address(0x1234567890123456789012345678901234567890);
    }

    // 203 gas
    function readConstant() public pure returns (bytes32) {
        return b;
    }
    
    // 195 gas
    function readImmutable() public view returns (address) {
        return a;
    }

    // 2248 gas (COLD SLOAD)
    function readMutable() public view returns (uint256) {
        return c;
    }
}
