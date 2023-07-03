// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

// Deployment cost: 9642 gas
contract Payable {
    constructor() payable {}

    // 74 gas
    function foo() external payable {}
}

// Deployment cost: 12066 gas
contract NonPayable {
    constructor() {}

    // 98 gas
    function bar() external {}
}
