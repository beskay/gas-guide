// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract Events {
    // Event declaration
    // Indexed parameters helps you filter the logs by the indexed parameter
    event LogStringIndexed(string indexed message1, string indexed message2, string indexed message3);
    event LogString(string message1, string message2, string message3);
    event LogNumIndexed(uint256 indexed num1, uint256 indexed num2, uint256 indexed num3);
    event LogNum(uint256 num1, uint256 num2, uint256 num3);

    // anonymous events
    event AnonymousLog(uint256 num1, uint256 num2, uint256 num3);

    // 1740 gas
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
