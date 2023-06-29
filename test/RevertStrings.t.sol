// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "src/RevertStrings.sol";

contract RevertStringsTest is Test {
    RevertShort public revertShort;
    RevertLong public revertLong;

    function setUp() public {
        revertLong = new RevertLong();
        revertShort = new RevertShort();
    }

    function testRevertLong() public {
        vm.expectRevert();
        vm.prank(address(12345));
        revertLong.setOwner();
    }

    function testRevertShort() public {
        vm.expectRevert();
        vm.prank(address(12345));
        revertShort.setOwner();
    }
}
