// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "src/BitShift.sol";

contract BitShiftTest is Test {
    BitShift public bitShift;
    NoBitShift public noBitShift;

    function setUp() public {
        bitShift = new BitShift();
        noBitShift = new NoBitShift();
    }

    function testDivideBitShift() public {
        uint256 a = 16;
        assertEq(bitShift.divide(a), 4);
    }

    function testDivideNoBitShift() public {
        uint256 a = 16;
        assertEq(noBitShift.divide(a), 4);
    }
}
