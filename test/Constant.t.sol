// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "src/Constant.sol";

contract ConstantTest is Test {
    Constant public instance;

    function setUp() public {
        instance = new Constant();
    }

    function testReadConstant() public view returns (bytes32) {
        return instance.readConstant();
    }

    function testReadImmutable() public view returns (address) {
        return instance.readImmutable();
    }

    function testReadMutable() public view returns (uint256) {
        return instance.readMutable();
    }
}
