// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "src/Constant.sol";

contract ConstantTest is Test {
    Constant public constantInstance;
    Immutable public immutableInstance;
    Mutable public mutableInstance;

    function setUp() public {
        constantInstance = new Constant();
        immutableInstance = new Immutable();
        mutableInstance = new Mutable();
    }

    function testReadConstant() public view returns (bytes32) {
        return constantInstance.readConstant();
    }

    function testReadImmutable() public view returns (address) {
        return immutableInstance.readImmutable();
    }

    function testReadMutable() public view returns (uint256) {
        return mutableInstance.readMutable();
    }
}
