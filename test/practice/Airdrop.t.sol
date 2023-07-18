// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "src/practice/Airdrop.sol";
import {BadERC20} from "src/practice/BadERC20.sol";

contract AirdropTest is Test {
    AirdropERC20 public instance;
    BadERC20 public token;

    function setUp() public {
        instance = new AirdropERC20();       
        token = new BadERC20();

        token.approve(address(instance), 1000_000 ether);
    }

    function testAirdrop() public {
        address[] memory addresses = new address[](500);
        uint256[] memory amounts = new uint256[](500);

        for (uint256 i = 0; i < 500; i++) {
            addresses[i] = address(uint160(i + 100));
            amounts[i] = 1000 ether;
        }

        instance.airdrop(address(token), address(this), addresses, amounts);
    }
}
