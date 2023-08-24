// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

// Deployment cost: 33687 gas
contract ModuloGood {
    // 274 gas
    function addMod(uint256 a) external pure returns (uint256) {
        return addmod(a, 1, 2);
    }

    // 296 gas
    function mulMod(uint256 a) external pure returns (uint256) {
        return mulmod(a, 1, 2);
    }
}

// Deployment cost: 61111 gas
contract ModuloBad {
    // 395 gas
    function addMod(uint256 a) external pure returns (uint256) {
        return (a + 1) % 2;
    }

    // 434 gas
    function mulMod(uint256 a) external pure returns (uint256) {
        return (a * 1) % 2;
    }
}
