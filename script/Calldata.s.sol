// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

/**
 * To see the gas costs of calldata in detail:
 * 1. Start a local node by typing `anvil` in your terminal
 * 2. Open a new terminal and run `forge script CalldataScript --rpc-url http://localhost:8545 --broadcast`
 * 3. Run some example commands, see below
 */

// Below tx will cost 23924 gas
// cast send 0x5fbdb2315678afecb367f032d93f642f64180aa3 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 "calldataTest(bytes)" "0x11"
// Now we are sending one additional nonzero byte, this will cost 23936 gas
// The difference is 12 gas: 16 gas for the nonzero byte, minus 4 gas which was already used for sending a zero byte

contract Calldata {
    event Log(bytes payload, uint256 size);

    function calldataTest(bytes calldata payload) external {
        uint256 a;

        // return calldatasize
        assembly {
            // store calldatasize in memory at position 0x0
            mstore(0x0, calldatasize())
            // load the value stored at 0x0 into a and return it
            a := mload(0x0)
        }

        emit Log(payload, a);
    }
}

contract CalldataScript is Script {
    function setUp() public {}

    function run() public {
        // private key of first anvil account
        vm.broadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);
        new Calldata();
    }
}
