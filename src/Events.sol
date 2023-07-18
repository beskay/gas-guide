// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract Events {
    // Event declaration
    // Indexed parameters helps you filter the logs by the indexed parameter
    event LogStringIndexed(string indexed, string indexed, string indexed);
    event LogString(string, string, string);
    event LogNumIndexed(uint256 indexed, uint256 indexed, uint256 indexed);
    event LogNum(uint256, uint256, uint256);

    // anonymous events
    event AnonymousLog(uint256, uint256, uint256) anonymous;

    // 1352 gas
    function anonLog() public {
        emit AnonymousLog(1, 2, 3);
    }

    // 1817 gas
    function logNum() public {
        emit LogNum(1, 2, 3);
    }

    // 2121 gas
    function logNumIndexed() public {
        emit LogNumIndexed(1, 2, 3);
    }

    // 2286 gas
    function logStringIndexed() public {
        emit LogStringIndexed("Hello", "World", "!");
    }

    // 3463 gas
    function logString() public {
        emit LogString("Hello", "World", "!");
    }
}
