// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract VariableCaching {
    uint256[10] myArray = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    uint256 sum;

    // 45495 gas
    function sumArrayOptimized() external  {
        uint256 length = myArray.length; // SLOAD
        uint256 localSum;

        for (uint256 i = 0; i < length; i++) {
            localSum += myArray[i]; // SLOAD
        }

        sum = localSum; // SSTORE
    }

    // 47506 gas
    function sumArray() external {
        for (uint256 i = 0; i < myArray.length; i++) { // SLOAD
            sum += myArray[i]; // SSTORE + 2x SLOAD
        }
    }
}
