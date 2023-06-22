// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "src/StoragePacking.sol";

// evm.storage

contract StoragePackingTest is Test {
    StoragePacking public instance;

    function setUp() public {
        instance = new StoragePacking();
    }

    function testWriteUint128() public {
        instance.writeUint128();
    }

    function testWriteUint256() public {
        instance.writeUint256();
    }

    function testWriteStruct() public {
        instance.writeStruct();
    }

    function testReadStruct() public view returns (StoragePacking.Entry memory) {
        return instance.readStruct();
    }
}
