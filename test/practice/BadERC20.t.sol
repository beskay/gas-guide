// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "src/practice/BadERC20.sol";

contract BadERC20Test is Test {
    BadERC20 public instance;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {        
        uint256 startGas = gasleft();
        instance = new BadERC20();
        uint256 gasUsed = startGas - gasleft();

        console.log("Deployment cost: %d gas", gasUsed);

        instance.transfer(alice, 1000_000 ether);
    }

    function testTransfer() public {
        instance.transfer(bob, 1000 ether);
    }

    function testTransferFrom() public {
        vm.prank(alice);
        instance.approve(address(this), 1000 ether);

        instance.transferFrom(alice, bob, 1000 ether);
    }
}
