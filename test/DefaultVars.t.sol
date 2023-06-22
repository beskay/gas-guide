// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "src/DefaultVars.sol";

contract DefaultVarsTest is Test {
    DefaultVarsOptimized public instance;
    DefaultVars public instance2;

    function setUp() public {}

    function testDefaultVarsOptimized() public {
        instance = new DefaultVarsOptimized();
    }

    function testDefaultVars() public {
        instance2 = new DefaultVars();
    }
}
