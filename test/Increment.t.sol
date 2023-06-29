// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "src/Increment.sol";

contract IncrementTest is Test {
    PostIncrement public postIncrement;
    PreIncrement public preIncrement;

    function setUp() public {
        postIncrement = new PostIncrement();
        preIncrement = new PreIncrement();
    }

    function testPostIncrement() public {
        postIncrement.postIncrement();
    }

    function testPreIncrement() public {
        preIncrement.preIncrement();
    }
}
