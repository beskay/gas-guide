// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "src/Modulo.sol";

contract ModuloTest is Test {
    ModuloGood public moduloGood;
    ModuloBad public moduloBad;

    function setUp() public {
        moduloGood = new ModuloGood();
        moduloBad = new ModuloBad();
    }

    function testAddModGood() public {
        uint256 a = 16;
        assertEq(moduloGood.addMod(a), 1);
    }

    function testAddModBad() public {
        uint256 a = 16;
        assertEq(moduloBad.addMod(a), 1);
    }

    function testMulModGood() public {
        uint256 a = 16;
        assertEq(moduloGood.mulMod(a), 0);
    }

    function testMulModBad() public {
        uint256 a = 16;
        assertEq(moduloBad.mulMod(a), 0);
    }
}
