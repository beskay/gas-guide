// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

// Deployment cost: 25275 gas
contract Greater {
    // 267 gas
    function greater(uint256 a, uint256 b) external pure returns (bool) {
        return a > b;
    }
}

// Deployment cost: 25475 gas
contract GreaterEqual {
    // 270 gas
    function greaterEqual(uint256 a, uint256 b) external pure returns (bool) {
        return a >= b;
    }
}

// Deployment cost: 25275 gas
contract Less {
    // 267 gas
    function less(uint256 a, uint256 b) external pure returns (bool) {
        return a < b;
    }
}

// Deployment cost: 25475 gas
contract LessEqual {
    // 270 gas
    function lessEqual(uint256 a, uint256 b) external pure returns (bool) {
        return a <= b;
    }
}

// Deployment cost: 25275 gas
contract Equal {
    // 270 gas
    function equal(uint256 a, uint256 b) external pure returns (bool) {
        return a == b;
    }
}

// Deployment cost: 25475 gas
contract NotEqual {
    // 270 gas
    function notEqual(uint256 a, uint256 b) external pure returns (bool) {
        return a != b;
    }
}

contract Comparison is Greater, GreaterEqual, Less, LessEqual, Equal, NotEqual {}
