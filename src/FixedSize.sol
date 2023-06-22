// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract FixedSize {
    uint256[10] fixedArray;
    uint256[] dynamicArray;

    bytes32 fixedBytes;
    bytes dynamicBytes;

    string myString;

    // 22260 gas
    function setFixedArray() public {
        fixedArray[0] = 1;
    }

    // 44440 gas
    function setDynamicArray() public {
        dynamicArray.push(1);
    }

    // 22244 gas
    function setFixedBytes() public {
        fixedBytes = "test test test test test";
    }

    // 22748 gas
    function setDynamicBytes() public {
        dynamicBytes = "test test test test test";
    }

    // 22682 gas
    function setString() public {
        myString = "test test test test test";
    }
}
