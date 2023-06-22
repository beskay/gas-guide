## Overview

### Storage related

Since storage operations are the most expensive gas opcodes, there is also the most potential to save gas costs.

- [Dont initialize default variables](#dont-initialize-default-variables)
- [Storage packing](#storage-packing)
- [Reduced-size types](#reduced-size-types)
- [Use constant and immutable state vars](#use-constant-and-immutable-state-vars)
- [Cache storage variables](#cache-storage-variables)
- [Fixed size variables are cheaper than dynamic size variables](#fixed-size-variables-are-cheaper-than-dynamic-size-variables)
- [Transient storage](#transient-storage)

### Other

COMING SOON

## Dont initialize default variables

The default value for all locations in contract storage is zero (`0` for `uint`, `false` for `bool`, `0x00..00` for address, ...). Initializing variables with their default value is therefore not necessary and is just a waste of gas.

[DefaultVars.sol](./contracts/DefaultVars.sol)

```solidity
// Deployment cost: 12666 gas
contract DefaultVarsOptimized {
    uint256 internal a;
    bool internal b;
    address internal c;
    bytes32 internal e;
}

// Deployment cost: 19308 gas
contract DefaultVars {
    uint256 internal a = 0;
    bool internal b = false;
    address internal c = address(0);
    bytes32 internal e = bytes32("");
}
```

Deploying the example contract with initialized default variables costs an additional ~6.6k gas, compared to the optimized version. If we take a look at the compiler generated Yul (`forge insect DefaultVars ir-optimized`), we see why:

```yul
/// @src 23:193:349  "contract DefaultVars {..."
let _1 := memoryguard(0x80)
mstore(64, _1)
if callvalue() { revert(0, 0) }
sstore(/** @src 23:241:242  "0" */ 0x00, 0x00)
/// @src 23:193:349  "contract DefaultVars {..."
sstore(/** @src 23:266:271  "false" */ 0x01, /** @src 23:193:349  "contract DefaultVars {..." */ and(sload(/** @src 23:266:271  "false" */ 0x01), /** @src 23:193:349  "contract DefaultVars {..." */ not(sub(shl(168, 1), 1))))
sstore(/** @src 23:335:346  "bytes32(\"\")" */ 0x02, /** @src 23:241:242  "0" */ 0x00)
/// @src 23:193:349  "contract DefaultVars {..."
let _2 := datasize("DefaultVars_29531_deployed")
codecopy(_1, dataoffset("DefaultVars_29531_deployed"), _2)
return(_1, _2)
```

There are three SSTORE instructions, each costs 2.2k gas (see `testZeroToZero()` in [StorageTest](./test/basics/Storage.t.sol) for more info).

Why are there only three sstore instructions, when we have 4 vars in total? The answer is variable packing. The compiler places the bool and the address in the same storage slot, since they both fit into 32 bytes, and so only a single SSTORE operation is necessary -> [Storage packing](#storage-packing).

**[⬆ back to top](#overview)**

## Storage packing

We can save storage by ordering variables which use less than 32 bytes next to each other.

Storage packing is particularly useful if you are reading or writing **multiple values in the same storage slot**. In this case only a single SLOAD or SSTORE operation is needed, which cuts the cost to access storage variables in half or more. This is usually the case with structs:

```solidity
struct Entry {
    uint128 id;
    uint128 value;
}
Entry f;

// Execution cost: 22323 gas
function writeStruct() external {
    // We are storing two variables, but only pay for a single SSTORE
    f = Entry(1, 2);
}
```

Below is the optimized yul code for function `writeStruct` in [StoragePacking.sol](./contracts/StoragePacking.sol). The compiler places the two uint128 variables in the same storage slot, and so only a single SSTORE operation is needed. `id` (0x01) is stored in the lower 128 bits of the storage slot (right aligned), and `value` (0x02) is stored in the upper 128 bits of the storage slot (left aligned).

```yul
case 0x33fe0dda { // writeStruct()
    if callvalue() { revert(_2, _2) }
    if slt(add(calldatasize(), not(3)), _2) { revert(_2, _2) }
    /// @src 38:1033:1044  "Entry(1, 2)"
    let expr_mpos := /** @src 38:492:1251  "contract StoragePacking is StorageLayout {..." */ allocate_memory()
    mstore(expr_mpos, /** @src 38:1039:1040  "1" */ 0x01)
    mstore(/** @src 38:1033:1044  "Entry(1, 2)" */ add(expr_mpos, 32), /** @src 38:1042:1043  "2" */ 0x02)
    // store Entry(1, 2);
    sstore(4, 0x0200000000000000000000000000000001)
    return(mload(64), _2)
}
```

### References

- https://github.com/dragonfly-xyz/useful-solidity-patterns/tree/main/patterns/packing-storage

**[⬆ back to top](#overview)**

## Reduced-size types

While storage packing usually saves gas, it is important to note that it can also increase gas usage. This is because the EVM operates on 32 bytes at a time. Therefore, if the element is smaller than that, the EVM must use more operations in order to reduce the size of the element from 32 bytes to the desired size. For example, see functions `writeUint128` and `writeUint256` in [StoragePacking.sol](./contracts/StoragePacking.sol).

```solidity
// Execution cost: 22306 gas
function writeUint256() external {
    ++b[0];
}

// Execution cost: 22557 gas
function writeUint128() external {
    // Writing to a single reduced size var is more expensive than writing to a uint256,
    // because the EVM always operates on 32 bytes.
    ++c[0];
}
```

Executing `writeUint128` costs 22557 gas while executing `writeUint256` costs 22306 gas. If we take a look at the output of `forge inspect StoragePacking ir-optimized` we can see that the compiler performs additional bit operations to reduce the size of the uint256 variable to 128 bits.

```yul
case 0x102f49a5 { // writeUint256()
    if callvalue() { revert(_2, _2) } // revert if called with value since function is nonpayable
    if slt(add(calldatasize(), not(3)), _2) { revert(_2, _2) }  // revert if calldata size is > 4 bytes
    let _3 := sload(/** @src 38:617:618  "b" */ 0x01)
    /// @src 38:492:1251  "contract StoragePacking is StorageLayout {..."
    if eq(_3, not(0)) // check if overflow, if yes revert with error code 0x11
    {
        mstore(_2, shl(224, 0x4e487b71))
        mstore(4, 0x11)
        revert(_2, 0x24)
    }
    sstore(/**  "b" */ 0x01, add(_3, /** "b" */ 0x01))
    /// @src 38:492:1251  "contract StoragePacking is StorageLayout {..."
    return(_1, _2)
}
case 0x11c3a83a { // writeUint128()
    if callvalue() { revert(_2, _2) } // revert if called with value since function is nonpayable
    if slt(add(calldatasize(), not(3)), _2) { revert(_2, _2) }  // revert if calldata size is > 4 bytes
    let _4 := sload(/** @src 38:861:862  "c" */ 0x03)
    /// @src 38:492:1251  "contract StoragePacking is StorageLayout {..."
    let _5 := 0xffffffffffffffffffffffffffffffff
    let value := and(_4, _5)
    if eq(value, _5) // check if _4 is greater than max(uint128)
    {
        mstore(_2, shl(224, 0x4e487b71))
        mstore(4, 0x11)
        revert(_2, 0x24)
    }
    // we have additional bitwise operations to store c in the lower 128 bits of the storage slot
    sstore(/** "c" */ 0x03, or(and(_4, not(0xffffffffffffffffffffffffffffffff)), and(add(value, 1), _5)))
    return(mload(64), _2)
}
```

### References

- https://docs.soliditylang.org/en/latest/internals/layout_in_storage.html#layout-of-state-variables-in-storage

**[⬆ back to top](#overview)**

## Use constant and immutable state vars

Compared to regular state variables, the gas costs of constant and immutable variables are much lower.

For a constant variable, the expression assigned to it is copied to all the places where it is accessed and also re-evaluated each time. This allows for local optimizations. Immutable variables are evaluated once at construction time and their value is copied to all the places in the code where they are accessed. For these values, 32 bytes are reserved, even if they would fit in fewer bytes. Due to this, constant values can sometimes be cheaper than immutable values.

If we debug the functions `readConstant()` and `readImmutable()` in [Constant.sol](./src/Constant.sol) we can see that instead of an `SLOAD` operation, the compiler replaced the immutable variable with `push32 value` and the constant variable with `push8 value`.

```solidity
// size(address) = 20 bytes, but 32 bytes are reserverd for immutable variables
// compiler will replace `a` with `PUSH32(address)`
address immutable a;

// 4 bytes, will be replaced with `PUSH4(0xaabbccdd)`
bytes32 constant b = bytes32(hex"AABBCCDD");

// 203 gas
function readConstant() public pure returns (bytes32) {
    return c;
}

// 195 gas
function readImmutable() public view returns (address) {
    return a;
}
```

Only value types (e.g. `bool`, `intN`/`uintN`, `address`, `bytesN`, `enum`) can be declared as immutable. All of the former types can be declared as constant as well, plus `string`, `bytes` and `contract` variables.

### References

- https://docs.soliditylang.org/en/latest/contracts.html#constant-and-immutable-state-variables
- https://medium.com/@ajaotosinserah/a-comprehensive-guide-to-implementing-constant-and-immutable-variables-in-solidity-4026ebadc6aa

**[⬆ back to top](#overview)**

## Fixed size variables are cheaper than dynamic size variables

As a general rule, use bytes for arbitrary-length raw byte data and string for arbitrary-length string (UTF-8) data. If you can limit the length to a certain number of bytes, always use one of the value types bytes1 to bytes32 because they are much cheaper.

The same applies for arrays. If you know that you will have at most a certain number of elements, always use a fixed array instead of a dynamic one. The reason is that a fixed array does not need a length parameter stored in storage and thus saves a slot.

```solidity
// 22260 gas
function setFixedArray() public {
    fixedArray[0] = 1;
}

// 44440 gas
function setDynamicArray() public {
    dynamicArray.push(1);
}

// 22244 gas
function setFixedBytes() public {
    fixedBytes = "test test test test test";
}

// 22748 gas
function setDynamicBytes() public {
    dynamicBytes = "test test test test test";
}
```

### References

- https://docs.soliditylang.org/en/v0.8.15/types.html#bytes-and-string-as-arrays

**[⬆ back to top](#overview)**

## Cache storage variables

Storage reads are expensive: The first `SLOAD` costs 2.1k gas, and all additional `SLOAD` operations cost 100 gas. Therefore, it is a good idea to cache storage variables in memory if a variable is read multiple times in the same function.

In the following example, we calculate the sum of elements in a storage array. Caching the array length and the resulting sum saves us around 2k gas per function call.

https://gist.github.com/hrkrshnn/a1165fc31cbbf1fae9f271c73830fdda
https://gist.github.com/hrkrshnn/ee8fabd532058307229d65dcd5836ddc

```solidity
uint256[10] myArray = [1, 2, 3, 4, 5, 6, 7, 8, 9];
uint256 sum;

// 45495 gas
function sumArrayOptimized() public  {
    uint256 length = myArray.length; // SLOAD
    uint256 localSum;

    for (uint256 i = 0; i < length; i++) {
        localSum += myArray[i]; // SLOAD
    }

    sum = localSum; // SSTORE
}

// 47506 gas
function sumArray() public {
    for (uint256 i = 0; i < myArray.length; i++) { // SLOAD
        sum += myArray[i]; // SSTORE + 2x SLOAD
    }
}
```

In the optimized function we have 11 SLOAD operations and 1 STORE operation in total. In the non-optimized function we have 30 SLOAD operations and 10 SSTORE operations, so why is the gas cost difference between them so small? The reason is the optimizer: It detects expressions that remain invariant in the loop and moves them outside of it (in our example: `myArray.length`). This reduces the difference to an additional 10 SLOAD and 9 SSTORE operations, each costing 100 gas.

### References

- https://gist.github.com/hrkrshnn/a1165fc31cbbf1fae9f271c73830fdda

**[⬆ back to top](#overview)**

## Transient storage

Transient storage is a special storage area that is only available during the execution of a call. Two new opcodes will be added to the EVM:

- TLOAD (0x05c)
- TSTORE (0x5d)

The gas costs for transient storage are much lower than for contract storage: Both cost 100 gas. A potential usecase for transient storage are reentrancy locks, reducing the gas costs from 5100 gas to 300 gas

```solidity
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call"); // BEFORE: 2.1k gas (SLOAD); AFTER: 100 gas (TLOAD)
        _status = _ENTERED; // BEFORE: 2.9k gas (SSTORE); AFTER: 100 gas (TSTORE)
        _;
        _status = _NOT_ENTERED; // BEFORE: 100 gas (SSTORE); AFTER: 100 gas (TSTORE)
    }
}
```

Transient storage will be included in the upcoming Cancun update.

### References

- https://eips.ethereum.org/EIPS/eip-1153
- https://ethereum-magicians.org/t/cancun-network-upgrade-meta-thread/12060/2

**[⬆ back to top](#overview)**
