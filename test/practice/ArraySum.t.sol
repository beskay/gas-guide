// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "src/practice/ArraySum.sol";

contract ArraySumTest is Test {
    ArraySum public instance;

    function setUp() public {
        instance = new ArraySum();
    }

    function testArraySum() public {
        uint256[] memory array = new uint256[](100);

        for (uint256 i = 0; i < 100; i++) {
            array[i] = i;
        }

        instance.sumIfEvenAndLessThan99(array);
    }

    function testGasOptimized() public {
        testArraySum();

        assertEq(instance.gasOptimized(38105), true);
    }
}
