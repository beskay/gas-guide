// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "src/practice/BadERC721.sol";

abstract contract ERC721TokenReceiver {
    function onERC721Received(address, address, uint256, bytes calldata) external virtual returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}

contract BadERC721Test is Test {
    OpenMint public instance;

    function setUp() public {
        uint256 startGas = gasleft();
        instance = new OpenMint("https://summon.mypinata.cloud/ipfs/QmPkeXk49oqBYckGeM5mzwNztVDGcsnCB7RwbCPKo5racj");
        uint256 gasUsed = startGas - gasleft();

        console.log("Deployment cost: %d gas", gasUsed);
    }

    function testMint() public {
        instance.freeMint();
    }

    function testBatchMint() public {
        // create memory array of 50 addresses
        address[] memory addresses = new address[](50);

        // fill array with sample addresses
        for (uint256 i = 0; i < 50; i++) {
            addresses[i] = address(uint160(i + 100));
        }

        // call batch mint with sample address array
        instance.batchMint(addresses);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external virtual returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}
