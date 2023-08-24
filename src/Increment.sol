// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

// Deployment cost: 24875 gas
contract PostIncrement {
    uint256 internal number;

    // 22308 gas (with the old codegen)
    // 22245 gas (--via-ir enabled)
    function postIncrement() external {
        number++;
    }
}

// Deployment cost: 24475 gas
contract PreIncrement {
    uint256 internal number;

    // 22303 gas (with the old codegen)
    // 22245 gas (--via-ir enabled)
    function preIncrement() external {
        ++number;
    }
}

// Used for inspecting the compiler generated Yul code
contract Increment {
    uint256 internal number;

    function postIncrement() external {
        number++;
    }

    function preIncrement() external {
        ++number;
    }
}
