// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "src/RequireChaining.sol";

contract RequireChainingTest is Test {
    RequireChaining public requireChaining;

    function setUp() public {
        requireChaining = new RequireChaining();
    }

    function testRequireChaining() public {
        requireChaining.requireChained();
    }

    function testRequireChainingBad() public {
        requireChaining.requireNotChained();
    }
}
