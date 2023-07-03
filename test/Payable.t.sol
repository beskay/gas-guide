// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "src/Payable.sol";

contract PayableTest is Test {
    Payable public payableContract;
    NonPayable public nonPayableContract;

    function setUp() public {
        payableContract = new Payable{value: 1 ether}();
        nonPayableContract = new NonPayable();
    }

    function testPayableFunction() public {
        payableContract.foo{value: 1 ether}();
    }

    function testNonPayableFunction() public {
        nonPayableContract.bar();
    }
}
