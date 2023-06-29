// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "src/Unchecked.sol";

contract UncheckedTest is Test {
    Unchecked public instance;

    function setUp() public {
        instance = new Unchecked();
    }

    function testIncrement() public {
        instance.increment();
    }

    function testIncrementUnchecked() public {
        instance.incrementUnchecked();
    }

    function testIncrementLoop() public view {
        instance.incrementLoop();
    }

    function testIncrementLoopUnchecked() public view {
        instance.incrementLoopUnchecked();
    }
}
