// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract Unchecked {
    uint256 internal number;

    // 22352 gas
    function increment() external {
        number++;
    }

    // 22247 gas
    function incrementUnchecked() external {
        unchecked {
            number++;
        }
    }

    // 11320 gas
    function incrementLoop() external pure {
        for (uint256 i = 0; i < 100; i++) {
            // do something;
        }
    }

    // 4454 gas
    function incrementLoopUnchecked() external pure {
        for (uint256 i = 0; i < 100;) {
            // do something
            unchecked {
                ++i;
            }
        }
    }
}
