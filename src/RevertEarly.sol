// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract RevertEarly {
    // 225 gas
    function earlyRevert() external pure {
        require(false, "Early revert");

        for (uint256 i = 0; i < 1000; i++) {
            // do nothing
        }
    }

    // 111290 gas
    function lateRevert() external pure {
        for (uint256 i = 0; i < 1000; i++) {
            // do nothing
        }
        require(false, "Late revert");
    }
}
