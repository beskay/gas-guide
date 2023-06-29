// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract PostIncrement {
    uint256 internal number;

    // 22308 gas (with the old codegen)
    // 22245 gas (--via-ir enabled)
    function postIncrement() public {
        number++;
    }
}

contract PreIncrement {
    uint256 internal number;

    // 22303 gas (with the old codegen)
    // 22245 gas (--via-ir enabled)
    function preIncrement() public {
        ++number;
    }
}

// Used for inspecting the compiler generated Yul code
contract Increment {
    uint256 internal number;

    function postIncrement() public {
        number++;
    }

    function preIncrement() public {
        ++number;
    }
}