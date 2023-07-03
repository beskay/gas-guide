// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "src/FunctionOrder.sol";

contract FunctionOrderTest is Test {
    FunctionOrder public functionOrder;

    function setUp() public {
        functionOrder = new FunctionOrder();
    }

    function testFunctionOrder() public view {
        functionOrder.a();
        functionOrder.b();
        functionOrder.c();
        functionOrder.d();
    }
}
