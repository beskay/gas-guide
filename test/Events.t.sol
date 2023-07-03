// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "src/Events.sol";

contract EventsTest is Test {
    Events public events;

    function setUp() public {
        events = new Events();
    }

    function testLogString() public {
        events.logString();
    }

    function testLogStringIndexed() public {
        events.logStringIndexed();
    }

    function testLogNum() public {
        events.logNum();
    }

    function testLogNumIndexed() public {
        events.logNumIndexed();
    }

    function testAnonLog() public {
        events.anonLog();
    }
}
