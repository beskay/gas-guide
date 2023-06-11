// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";

contract StorageTest is Test {
    uint256 internal a;
    uint256 internal b = 1;

    function setUp() public {}

    // 22.1k gas
    // G_sset + G_coldsload = 20k gas + 2.1k gas
    function testZeroToNonzero() public {
        a = 1;
    }

    // Refund 4800 gas per cleared storage var (since EIP-3529)
    // Refunds are capped to gas_used / 5
    function testNonzeroToZero() public {
        a = 1; // 20k gas
        b = 0; // G_sreset + G_coldsload - refund = 200 gas
    }

    // 5000 gas
    // G_sreset + G_coldsload = 2900 gas + 2100 gas
    function testNonzeroToNonzero() public {
        b = 2;
    }

    // 2200 gas
    // G_coldsload + G_warmaccess = 2100 gas + 100 gas
    function testZeroToZero() public {
        a = 0;
    }

    // 2100 gas
    // G_coldsload = 2100 gas
    function testReadStorageCold() public view returns (uint256) {
        uint256 temp = b; // G_coldsload = 2100 gas

        return temp;
    }

    // 2200 gas
    // G_coldsload + G_warmaccess = 2100 gas + 100 gas
    function testReadStorageWarm() public view returns (uint256) {
        uint256 temp = b; // G_coldsload = 2100 gas
        temp = b; // G_warmaccess = 100 gas

        return temp;
    }
}
