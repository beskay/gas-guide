// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "src/RevertEarly.sol";

contract RevertEarlyTest is Test {
    RevertEarly public revertEarly;

    function setUp() public {
        revertEarly = new RevertEarly();
    }

    function testEarlyRevert() public {
        vm.expectRevert();
        revertEarly.earlyRevert();
    }

    function testLateRevert() public {
        vm.expectRevert();
        revertEarly.lateRevert();
    }
}
