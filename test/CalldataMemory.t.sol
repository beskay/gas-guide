// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "src/CalldataMemory.sol";

contract CalldataMemoryTest is Test {
    CalldataMemory public instance;

    function setUp() public {
        instance = new CalldataMemory();
    }

    function testArgAsCalldata() public view {
        instance.argAsCalldata("test");
    }

    function testArgAsMemory() public view {
        instance.argAsMemory("test");
    }
}
