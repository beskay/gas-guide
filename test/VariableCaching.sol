// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "src/VariableCaching.sol";

contract VariableCachingTest is Test {
    VariableCaching public instance;

    function setUp() public {
        instance = new VariableCaching();
    }

    function testSumArrayOptimized() public {
        instance.sumArrayOptimized();
    }

    function testSumArray() public {
        instance.sumArray();
    }
}
