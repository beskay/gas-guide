// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "src/CustomError.sol";

contract CustomErrorTest is Test {
    CustomError public customError;
    RequireError public requireError;

    function setUp() public {
        customError = new CustomError();
        requireError = new RequireError();
    }

    function testCustomError() public {
        vm.expectRevert();
        vm.prank(address(12345));
        customError.setOwner();
    }

    function testRequireError() public {
        vm.expectRevert();
        vm.prank(address(12345));
        requireError.setOwner();
    }
}
