// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract ArraySum {
    // you are allowed to change these state vars, but not to remove them
    uint256 public total;
    uint256 gasUsed;

    // optimize the for loop in this function
    function sumIfEvenAndLessThan99(uint256[] memory nums) external {
        uint256 startGas = gasleft();

        for (uint256 i = 0; i < nums.length; i += 1) {
            bool isEven = nums[i] % 2 == 0;
            bool isLessThan99 = nums[i] < 99;
            if (isEven && isLessThan99) {
                total += nums[i];
            }
        }

        gasUsed = startGas - gasleft();
    }

    // dont modify this function
    function gasOptimized(uint256 optimizedGas) public view returns (bool) {
        if (gasUsed < optimizedGas) {
            return true;
        } else {
            return false;
        }
    }
}
