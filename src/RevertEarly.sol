// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract RevertEarly {
    // 225 gas
    function earlyRevert() public pure {
        require(false, "Early revert");
        
        for (uint i = 0; i < 1000; i++) {
            // do nothing
        }
    }


    // 111290 gas
    function lateRevert() public pure {
        for (uint i = 0; i < 1000; i++) {
            // do nothing
        }
        require(false, "Late revert");
    }
}

