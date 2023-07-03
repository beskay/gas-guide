// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract Greater {
    // 267 gas
    function greater(uint256 a, uint256 b) external pure returns (bool) {
        return a > b;
    }
}

contract GreaterEqual {
    // 270 gas
    function greaterEqual(uint256 a, uint256 b) external pure returns (bool) {
        return a >= b;
    }
}

contract Less {
    // 267 gas
    function less(uint256 a, uint256 b) external pure returns (bool) {
        return a < b;
    }
}

contract LessEqual {
    // 270 gas
    function lessEqual(uint256 a, uint256 b) external pure returns (bool) {
        return a <= b;
    }
}

contract Equal {
    // 270 gas
    function equal(uint256 a, uint256 b) external pure returns (bool) {
        return a == b;
    }
}

contract NotEqual {
    // 270 gas
    function notEqual(uint256 a, uint256 b) external pure returns (bool) {
        return a != b;
    }
}

contract Comparison is Greater, GreaterEqual, Less, LessEqual, Equal, NotEqual {}