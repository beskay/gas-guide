// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "src/Comparison.sol";

contract ComparisonTest is Test {
    Greater public greater;
    GreaterEqual public greaterEqual;
    Less public less;
    LessEqual public lessEqual;
    Equal public equal;
    NotEqual public notEqual;


    function setUp() public {
        greater = new Greater();
        greaterEqual = new GreaterEqual();
        less = new Less();
        lessEqual = new LessEqual();
        equal = new Equal();
        notEqual = new NotEqual();
    }

    function testGreater() public {
        assertTrue(greater.greater(3, 2));
    }

    function testGreaterEqual() public {
        assertTrue(greaterEqual.greaterEqual(3, 2));
    }

    function testLess() public {
        assertTrue(less.less(2, 3));
    }

    function testLessEqual() public {
        assertTrue(lessEqual.lessEqual(2, 3));
    }

    function testEqual() public {
        assertTrue(equal.equal(3, 3));
    }

    function testNotEqual() public {
        assertTrue(notEqual.notEqual(3, 2));
    }
}
