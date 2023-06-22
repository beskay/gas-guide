// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

// Deployment cost: 12666 gas
contract DefaultVarsOptimized {
    uint256 internal a;
    bool internal b;
    address internal c;
    bytes32 internal e;
}

// Deployment cost: 19308 gas
contract DefaultVars {
    uint256 internal a = 0;
    bool internal b = false;
    address internal c = address(0);
    bytes32 internal e = bytes32("");
}
