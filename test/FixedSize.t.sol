// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "src/FixedSize.sol";

contract FixedSizeTest is Test {
    FixedSize public instance;

    function setUp() public {
        instance = new FixedSize();
    }

    function testSetFixedArray() public {
        instance.setFixedArray();
    }

    function testSetDynamicArray() public {
        instance.setDynamicArray();
    }

    function testSetFixedBytes() public {
        instance.setFixedBytes();
    }

    function testSetDynamicBytes() public {
        instance.setDynamicBytes();
    }

    function testSetString() public {
        instance.setString();
    }
}
