// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract FunctionOrder {
    // 98 gas
    function a() external pure{}
    
    // 120 gas
    function b() external pure{}

    // 164 gas
    function c() external pure{}

    // 142 gas
    function d() external pure{}
}
