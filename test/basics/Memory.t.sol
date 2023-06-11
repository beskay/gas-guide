// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";

contract MemoryTest is Test {
    function setUp() public {}

    // 222 gas
    function testReadMemory() public pure returns (uint256) {
        uint256 temp = 1;

        return temp;
    }

    // 187 gas
    function testSetMemory() public pure {
        uint256 temp = 1;
        temp = 2;
    }

    // 8278 gas
    function testMemExpansionSmall() public pure {
        uint256[1000] memory temp;

        // to silence compiler warning
        temp[0] = 1;
    }

    // 255810
    // We only write ten times more data to memory, but it costs ~31 times more gas
    function testMemExpansionMedium() public pure {
        uint256[10000] memory temp;

        // to silence compiler warning
        temp[0] = 1;
    }

    // 20133154
    // 100x more data, ~2432x more gas compared to testMemExpansionSmall
    function testMemExpansionBig() public pure {
        uint256[100000] memory temp;

        // to silence compiler warning
        temp[0] = 1;
    }

    function testMemAllocation() public pure returns (address memptr, address memptr2) {
        // memptr is 0x80 (location of free memory pointer)
        assembly {
            memptr := mload(0x40)
        }

        // we call a random function which allocates two uint16 in memory
        _allocateMemory();

        // memory is not cleared, new location of free memory pointer is 0xC0
        // which is 64 bytes higher than the previous location
        // we also see that each memory slot reserves 32 bytes, regardless of size
        assembly {
            memptr2 := mload(0x40)
        }
    }

    function _allocateMemory() internal pure {
        uint16[2] memory temp;

        // to silence compiler warning
        temp[0] = 1;

        // we dont have to return temp, since memory is not cleared between function calls
    }
}
