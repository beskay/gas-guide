# Optimizations

### Storage related

Since storage operations are among the most expensive opcodes, there is also the most potential to save gas costs.

- [Dont initialize default variables](#dont-initialize-default-variables)
- [Storage packing](#storage-packing)
- [Reduced-size types](#reduced-size-types)
- [Use constant and immutable state vars](#use-constant-and-immutable-state-vars)
- [Cache storage variables](#cache-storage-variables)
- [Fixed size variables are cheaper than dynamic size variables](#fixed-size-variables-are-cheaper-than-dynamic-size-variables)
- [Transient storage](#transient-storage)

### Error handling

- [Custom errors](#custom-errors)
- [Short revert strings](#short-revert-strings)
- [Revert as early as possible](#revert-as-early-as-possible)
- [Require chaining](#require-chaining)

### Math

- [Use unchecked{} when possible (e.g. loops)](#use-unchecked-when-possible-eg-loops)
- [Pre-increment vs. post-increment](#pre-increment-vs-post-increment)
- [Use < or > instead of <= or >=](#use--or--instead-of--or-)
- [Short circuit when checking conditionals](#short-circuit-when-checking-conditionals)
- [Bit shifting when multiplying/dividing by powers of 2](#bit-shifting-when-multiplyingdividing-by-powers-of-2)
- [addmod() and mulmod()](#addmod-and-mulmod)

### Functions

- [Calldata instead of memory for external functions](#calldata-instead-of-memory-for-external-functions)
- [Declare functions as payable](#declare-functions-as-payable)
- [Function order matters](#function-order-matters)
- [Limit modifiers](#limit-modifiers)
- [Indexed events](#indexed-events)

### Other

- [Multicall for batch transactions](https://github.com/dragonfly-xyz/useful-solidity-patterns/tree/main/patterns/multicall)
- [Off-chain storage](https://github.com/dragonfly-xyz/useful-solidity-patterns/tree/main/patterns/off-chain-storage)
- [Big data storage (SSTORE2)](https://github.com/dragonfly-xyz/useful-solidity-patterns/tree/main/patterns/big-data-storage)

---

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

Deploying the example contract with initialized default variables costs an additional ~6.6k gas, compared to the optimized version. If we take a look at the compiler generated Yul (`forge inspect DefaultVars ir-optimized`), we see why:

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

There are three SSTORE instructions, each costing 2.2k gas (see `testZeroToZero()` in [StorageTest](./test/basics/Storage.t.sol) for more information).

Why are there only three sstore instructions, when we have 4 vars in total? The answer is variable packing. The compiler places the bool and the address in the same storage slot since they both fit into 32 bytes. Therefore, only a single SSTORE operation is necessary -> [Storage packing](#storage-packing).

### forge commands

- `forge test --mc DefaultVarsTest -vvvv` - run gas tests
- `forge inspect DefaultVars ir-optimized` - show optimized yul code

**[⬆ back to top](#optimizations)**

## Storage packing

We can save storage by ordering variables that use less than 32 bytes next to each other.

Storage packing is particularly useful when reading or writing **multiple values in the same storage slot**. In such cases, only a single SLOAD or SSTORE operation is needed, significantly reducing the cost of accessing storage variables by half or more. This situation commonly occurs with structs:

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

Below is the optimized Yul code for function `writeStruct` in [StoragePacking.sol](./src/StoragePacking.sol). The compiler places the two uint128 variables in the same storage slot, so only a single SSTORE operation is needed. `id` (0x01) is stored in the lower 128 bits of the storage slot (right-aligned), and `value` (0x02) is stored in the upper 128 bits of the storage slot (left-aligned).

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

### forge commands

- `forge test --mc StoragePackingTest -vvvv` - run gas tests
- `forge inspect StoragePackingTest ir-optimized` - show optimized yul code

### References

- https://github.com/dragonfly-xyz/useful-solidity-patterns/tree/main/patterns/packing-storage

**[⬆ back to top](#optimizations)**

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

Executing writeUint128 costs 22,557 gas, while executing writeUint256 costs 22,306 gas. By examining the output of `forge inspect StoragePacking ir-optimized`, we can observe that the compiler performs additional bit operations to reduce the size of the uint256 variable to 128 bits.

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

### forge commands

- `forge test --mc StoragePackingTest -vvvv` - run gas tests
- `forge inspect StoragePackingTest ir-optimized` - show optimized yul code

### References

- https://docs.soliditylang.org/en/latest/internals/layout_in_storage.html#layout-of-state-variables-in-storage

**[⬆ back to top](#optimizations)**

## Use constant and immutable state vars

Compared to regular state variables, the gas costs of constant and immutable variables are much lower.

For a constant variable, the expression assigned to it is copied to all the places where it is accessed and also re-evaluated each time. This allows for local optimizations. Immutable variables are evaluated once at construction time and their value is copied to all the places in the code where they are accessed. For these values, 32 bytes are reserved, even if they would fit in fewer bytes. Due to this, constant values can sometimes be cheaper than immutable values.

If we debug the functions `readConstant()` and `readImmutable()` in [Constant.sol](./src/Constant.sol), we can see that instead of an `SLOAD` operation, the compiler replaced the immutable variable with `push32 value` and the constant variable with `push8 value`.

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

### forge commands

- `forge test --mc ConstantTest -vvvv` - run gas tests
- `forge inspect ConstantTest ir-optimized` - show optimized yul code

### References

- https://docs.soliditylang.org/en/latest/contracts.html#constant-and-immutable-state-variables
- https://medium.com/@ajaotosinserah/a-comprehensive-guide-to-implementing-constant-and-immutable-variables-in-solidity-4026ebadc6aa

**[⬆ back to top](#optimizations)**

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

### forge commands

- `forge test --mc FixedSizeTest -vvvv` - run gas tests
- `forge inspect FixedSizeTest ir-optimized` - show optimized yul code

### References

- https://docs.soliditylang.org/en/v0.8.15/types.html#bytes-and-string-as-arrays

**[⬆ back to top](#optimizations)**

## Cache storage variables

Storage reads are expensive: The first `SLOAD` costs 2.1k gas, and all additional `SLOAD` operations cost 100 gas. Therefore, it is a good idea to cache storage variables in memory if a variable is read multiple times in the same function.

In the following example, we calculate the sum of elements in a storage array. Caching the array length and the resulting sum saves us around 2k gas per function call.

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

In the optimized function, we have a total of 11 SLOAD operations and 1 SSTORE operation. In the non-optimized function, we have 30 SLOAD operations and 10 SSTORE operations. However, the gas cost difference between them is relatively small. The reason for this is the optimizer: It detects expressions that remain invariant in the loop and moves them outside of it. In our example, the expression `myArray.length` is invariant, so it is moved outside of the loop. This reduces the difference to an additional 10 SLOAD operations and 9 SSTORE operations, each costing 100 gas.

### forge commands

- `forge test --mc VariableCachingTest -vvvv` - run gas tests
- `forge inspect VariableCachingTest ir-optimized` - show optimized yul code

### References

- https://gist.github.com/hrkrshnn/a1165fc31cbbf1fae9f271c73830fdda

**[⬆ back to top](#optimizations)**

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

**[⬆ back to top](#optimizations)**

## Use unchecked{} when possible (e.g. loops)

Solidity provides two ways to perform arithmetic operations: checked and unchecked. Checked operations throw an exception if an overflow or underflow occurs, while unchecked operations do not.

Using `unchecked{}` is particularly useful in for loops for the incremented value because it is impossible to overflow without running out of gas first (in normal conditions).

```solidity
// 22352 gas
function increment() public {
    number++;
}

// 22247 gas
function incrementUnchecked() public {
    unchecked {
        number++;
    }
}
```

If we inspect the Yul code, we can observe that the function `increment_uint256(value)` is called when we increment `number`. On the other hand, `unchecked { number++; }` is compiled to `sstore(_2, add(sload(_2), 1))`. This means that the number is incremented directly without performing any checks.

```yul
let _2 := 0

case 0xc7fd0347 { // incrementUnchecked()
    if callvalue() { revert(_2, _2) }
    if slt(add(calldatasize(), not(3)), _2) { revert(_2, _2) }
    sstore(_2, add(sload(_2), 1))
    return(_1, _2)
}
case 0xd09de08a { // increment()
    if callvalue() { revert(_2, _2) }
    if slt(add(calldatasize(), not(3)), _2) { revert(_2, _2) }
    sstore(_2, increment_uint256(sload(_2)))
    return(mload(64), _2)
}

function increment_uint256(value) -> ret
{
    if eq(value, not(0)) // overflow / underflow check
    {
        mstore(0, shl(224, 0x4e487b71))
        mstore(4, 0x11)
        revert(0, 0x24)
    }
    ret := add(value, 1)
}
```

### forge commands

- `forge test --mc UncheckedTest -vvvv` - run gas tests
- `forge inspect Unchecked ir-optimized` - show optimized yul code

**[⬆ back to top](#optimizations)**

## Pre-increment vs. Post-increment

One of the most well-known gas optimization tricks is using `++i` instead of `i++`. The former is slightly cheaper because `i++` saves the original value before incrementing it, requiring an extra DUP and POP opcode, which consume 3 and 2 gas respectively.

However, this optimization is specific to the old compiler. In the new IR-based compilation (via_ir = true), this difference in gas costs is optimized away. As a result, there is no longer any distinction in gas costs between `++i` and `i++`.

```solidity
function postIncrement() public {
    number++;
}

function preIncrement() public {
    ++number;
}
```

Results in:

```yul
case 0x016e4842 { // postIncrement()
    if callvalue() { revert(_1, _1) }
    if slt(add(calldatasize(), not(3)), _1) { revert(_1, _1) }
    sstore(_1, increment_uint256(sload(_1)))
    return(mload(64), _1)
}
case 0x5b59b0c8 { // preIncrement()
    if callvalue() { revert(_1, _1) }
    if slt(add(calldatasize(), not(3)), _1) { revert(_1, _1) }
    sstore(_1, increment_uint256(sload(_1)))
    return(mload(64), _1)
}
```

### forge commands

- `forge test --mc IncrementTest -vvvv` - run gas tests
- `forge test --mc IncrementTest -vvvv --via-ir` - run gas tests with IR-based compilation
- `forge inspect Increment ir-optimized` - show optimized yul code

### References

- https://twitter.com/0xCygaar/status/1607860326271438848
- https://twitter.com/beskay0x/status/1673419658555191316

**[⬆ back to top](#optimizations)**

## Calldata instead of memory for external functions

Calldata is cheaper than memory. If the input argument does not need to be modified, consider using calldata in external functions:

```solidity
// 391 gas
function argAsCalldata(string calldata name) external pure {}

// 515 gas
function argAsMemory(string memory name) external pure {}
```

If `calldata` is used, the data is read directly via `calldataload`. On the other hand, if `memory` is used, the data is copied to memory first, which is more expensive.

### forge commands

- `forge test --mc CalldataMemoryTest -vvvv` - run gas tests

### References

- https://gist.github.com/hrkrshnn/ee8fabd532058307229d65dcd5836ddc#use-calldata-instead-of-memory-for-function-parameters

**[⬆ back to top](#optimizations)**

## Use custom errors

The usage of custom errors provides a gas-efficient way to revert a transaction, both in terms of execution cost and deployment cost.

Custom errors are defined using the error statement, which can be used inside and outside of contracts, including interfaces and libraries.

The following example demonstrates the usage of custom errors:

```solidity
error OnlyOwner();

contract CustomError {
    address owner = msg.sender;

    function setOwner() public {
        if (msg.sender != owner) revert OnlyOwner();

        owner = msg.sender;
    }
}
```

Inspecting the Yul code, we see that the traditional `require` error statement needs several `mstore` opcodes, while the custom error only needs one (for the error signature):

```yul
// require(msg.sender == owner, "Only owner can call this function");
if iszero(eq(caller(), and(_3, sub(shl(160, 1), 1))))
{
    mstore(_1, shl(229, 4594637))
    mstore(add(_1, 4), 32)
    mstore(add(_1, 36), 33)
    mstore(add(_1, 68), "Only owner can call this functio")
    mstore(add(_1, 100), "n")
    revert(_1, 132)
}

// error OnlyOwner()
if iszero(eq(caller(), and(_3, sub(shl(160, 1), 1))))
{
    /// @src 38:210:221  "OnlyOwner()"
    mstore(_1, shl(224, 0x5fc483c5))
    revert(_1, /** @src 38:81:267  "contract CustomError {..." */ 4)
}
```

We can also see that each 32-byte chunk (32 characters) of the revert string requires an additional `mstore` opcode. This leads us to the next gas optimization trick: short revert strings.

### forge commands

- `forge test --mc CustomErrorTest -vvvv` - run gas tests
- `forge inspect CustomError ir-optimized` - show optimized yul code

### References

- https://blog.soliditylang.org/2021/04/21/custom-errors/

**[⬆ back to top](#optimizations)**

## Short revert strings

Try to keep the length of your error strings below 32 characters, if you handle errors with the `require` statement to limit the usage of `mstore` opcodes. The shorter your revert strings, the cheaper the deployment costs as well.

```solidity
// Deployment cost: 53416 gas
contract RevertShort {
    address owner = msg.sender;

    // 2363 gas
    function setOwner() public {
        require(msg.sender == owner, "!owner");

        owner = msg.sender;
    }
}

// Deployment cost: 60222 gas
contract RevertLong {
    address owner = msg.sender;

    // 2381 gas
    function setOwner() public {
        require(msg.sender == owner, "Only the contract owner can call this function!");

        owner = msg.sender;
    }
}
```

### forge commands

- `forge test --mc RevertStringsTest -vvvv` - run gas tests
- `forge inspect RevertStrings ir-optimized` - show optimized yul code

### References

- https://gist.github.com/hrkrshnn/ee8fabd532058307229d65dcd5836ddc#consider-having-short-revert-strings

**[⬆ back to top](#optimizations)**

## Revert as early as possible

The execution of a function costs gas. The more code you execute, the more gas you will spend. Therefore, it is a good idea to revert as early as possible.

```solidity
// 225 gas
function earlyRevert() public {
    require(false, "Early revert");
}


// 111290 gas
function lateRevert() public {
    for (uint i = 0; i < 1000; i++) {
        // do nothing
    }
    require(false, "Late revert");
}
```

### forge commands

- `forge test --mc RevertEarlyTest -vvvv` - run gas tests

**[⬆ back to top](#optimizations)**

## Require chaining

If you have multiple conditions that need to be checked, it is recommended not to combine them using `&&` or `||`. Instead, use require chaining, where each condition is checked separately using multiple require statements.

However, it is important to note that if you use error strings in your require statements, the deployment costs of the contract will increase.

```solidity
// 2279 gas
function requireChained() public payable {
    require(msg.sender == owner);
    require(msg.value == 0);
    require(block.timestamp < 1000_000);
}

// 2317 gas
function requireNotChained() public payable {
    require(msg.sender == owner && msg.value == 0 && block.timestamp < 1000_000);
}
```

### forge commands

- `forge test --mc RequireChainingTest -vvvv` - run gas tests

**[⬆ back to top](#optimizations)**

## Use < or > instead of <= or >=

In Solidity, there is no specific opcode for expressions like `>=` or `<=`. If you use `>=` or `<=`, the compiler will generate an additional `iszero` opcode, which costs an extra 3 gas.

To check if a value is greater or less than another value, it is recommended to use `<` or `>` operators instead, as they do not require the additional `iszero` opcode.

```solidity
// 267 gas
function greater(uint256 a, uint256 b) external pure returns (bool) {
    return a > b;
}

// 270 gas
function greaterEqual(uint256 a, uint256 b) external pure returns (bool) {
    return a >= b;
}
```

If we inspect the Yul code, we can see the additional `isZero` instruction:

```yul
// Greater
mstore(_1, gt(calldataload(4), calldataload(36)))

// GreaterEqual
mstore(_1, iszero(lt(calldataload(4), calldataload(36))))
```

### forge commands

- `forge test --mc ComparisonTest -vvvv` - run gas tests
- `forge inspect Comparison ir-optimized` - show optimized yul code

**[⬆ back to top](#optimizations)**

## Short circuit when checking conditionals

When checking multiple conditions with the `&&` operator, place the condition which is most likely to fail first. This way, if the first condition fails, the second condition will not be checked.

On the other hand, when using the `||` operator, it is recommended to place the condition that is most likely to succeed first. This way, if the first condition succeeds (evaluates to true), the second condition will not be evaluated, optimizing gas usage.

**[⬆ back to top](#optimizations)**

## Bit shifting when multiplying/dividing by powers of 2

If you need to divide or multiply a number by a power of two, you can optimize the operation by using bit shifting instead. Right shift (`>>`) is equivalent to division by 2, while left shift (`<<`) is equivalent to multiplication by 2.

```solidity
// 241 gas
function divide(uint256 a) external pure returns (uint256) {
    return a >> 2; // divide by 2^2 = 4
}

// 317 gas
function divide(uint256 a) external pure returns (uint256) {
    return a / 4;
}
```

Note: This optimization is "optimized away" when the IR-based compiler (via_ir=true) is enabled. In this case, both functions are compiled to the same output and cost 153 gas.

```yul
if eq(0x3e823f79, shr(224, calldataload(0)))
{
    if callvalue() { revert(0, 0) }
    if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
    mstore(_1, shr(0x02, calldataload(4)))
    return(_1, 32)
}
```

### forge commands

- `forge test --mc BitShiftTest -vvvv` - run gas tests
- `forge inspect BitShift ir-optimized` - show optimized yul code
- `forge inspect NoBitShift ir-optimized` - show optimized yul code

**[⬆ back to top](#optimizations)**

## addmod() and mulmod()

When performing modulo operations, use `addmod()` and `mulmod()`, which combine the arithmetic and modulo operation in a single step.

```solidity
// 274 gas
function addMod(uint256 a) external pure returns (uint256) {
    return addmod(a, 1, 2);
}

// 395 gas
function addMod(uint256 a) external pure returns (uint256) {
    return (a + 1) % 2;
}

// 296 gas
function mulMod (uint256 a) external pure returns (uint256) {
    return mulmod(a, 1, 2);
}

// 434 gas
function mulMod (uint256 a) external pure returns (uint256) {
    return (a * 1) % 2;
}
```

Comparing the two `addMod` functions in Yul, it becomes apparent why using `addmod` or `mulmod` can be cheaper: Since `addmod` or `mulmod` is designed to handle overflow automatically, there is no need for an extra overflow check.

```yul
case 0xb1d818a1 { // addModBad
    if callvalue() { revert(_2, _2) }
    if slt(add(calldatasize(), not(3)), 32) { revert(_2, _2) }
    let value := calldataload(4)
    if gt(value, add(value, 1))
    {
        mstore(_2, shl(224, 0x4e487b71))
        mstore(4, 0x11)
        revert(_2, 0x24)
    }
    mstore(_1, addmod(value, 1, 0x02))
    return(_1, 32)
}

case 0xb1d818a1 { // addModGood
    if callvalue() { revert(_2, _2) }
    if slt(add(calldatasize(), not(3)), 32) { revert(_2, _2) }
    mstore(_1, addmod(calldataload(4), 1, 0x02))
    return(_1, 32)
}
```

### forge commands

- `forge test --mc ModuloTest -vvvv` - run gas tests
- `forge inspect ModuloGood ir-optimized` - show optimized yul code
- `forge inspect ModuloBad ir-optimized` - show optimized yul code

**[⬆ back to top](#optimizations)**

## Declare functions as payable

By default, functions in Solidity are non-payable, meaning they do not accept Ether payments. However, if you explicitly declare a function as payable, the compiler will omit the `msg.value == zero` check when calling that function. This optimization can result in gas savings since the check for zero value is not necessary.

```solidity
// Deployment cost: 9642 gas
contract Payable {
    constructor() payable {}

    // 74 gas
    function foo() external payable {}
}

// Deployment cost: 12066 gas
contract NonPayable {
    constructor() {}

    // 98 gas
    function bar() external {}
}
```

Inspecting the Yul code [Payable.yulp](./src/ir-optimized/Payable.yulp), we can see that this line is removed

```yul
if callvalue() { revert(0, 0) }
```

It's important to note that declaring a function as payable should only be done when the function actually needs to receive Ether payments. Otherwise, it is recommended to keep the function as non-payable to ensure proper handling of Ether transactions and avoid unintended behaviors.

### forge commands

- `forge test --mc PayableTest -vvvv` - run gas tests
- `forge inspect Payable ir-optimized` - show optimized yul code
- `forge inspect NonPayable ir-optimized` - show optimized yul code

**[⬆ back to top](#optimizations)**

## Function order matters

When calling a function, the EVM jumps through the list of function selectors until it finds a match. The function selectors are ordered in hexadecimal order and each jump costs 22 gas. If you have a lot of functions, you can save gas by ordering them in a way that the most commonly called functions are at the top.

For example, consider the following contract:

```solidity
contract FunctionOrder {
    function a() external pure{}

    function b() external pure{}

    function c() external pure{}

    function d() external pure{}
}
```

Displaying the function selectors with `forge inspect FunctionOrder methods` shows:

```js
{
  "a()": "0dbe671f",
  "b()": "4df7e3d0",
  "c()": "c3da42b8",
  "d()": "8a054ac2"
}
```

Since the function selectors are ordered in hexadecimal order, the order of the functions is `a, b, d, c`. By inspecting the Yul code, we can confirm that this is the case:

```yul
{
    switch shr(224, calldataload(0))
    case 0x0dbe671f { external_fun_a() } // a
    case 0x4df7e3d0 { external_fun_a() } // b
    case 0x8a054ac2 { external_fun_a() } // d
    case 0xc3da42b8 { external_fun_a() } // c
}
```

### forge commands

- `forge test --mc FunctionOrderTest -vvvv` - run gas tests
- `forge inspect FunctionOrder methods` - show function selectors
- `forge inspect FunctionOrder ir-optimized` - show optimized yul code

**[⬆ back to top](#optimizations)**

## Limit modifiers

When you add a function modifier in Solidity, the code of the modified function is inserted into the modifier. If the same modifier is used multiple times, the code is duplicated, increasing the bytecode size. On the other hand, internal functions are called separately and save bytecode in deployment. Internal functions incur a slight runtime cost due to function calls. This means they are slightly more expensive in execution costs but save a lot of redundant bytecode in deployment.

### References

- https://github.com/OpenZeppelin/openzeppelin-contracts/pull/3223
- https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

**[⬆ back to top](#optimizations)**

## Indexed events

You can include up to three (four for anonymous events) indexed parameters in an event in Solidity. These indexed parameters are stored in a special data structure called "topics" instead of the data part of the event log. The first topic of an event is always the event signature, unless the event is declared as anonymous.

Using indexed parameters allows you to efficiently search for specific events when filtering a sequence of blocks. Each indexed parameter included in an event costs an additional 375 gas.

```
Gas costs of events:
static_gas = 375
dynamic_gas = 375 * topic_count + 8 * size + memory_expansion_cost
```

Depending on the type of parameter it is cheaper to not declare it as indexed. For example, string parameters are cheaper to declare as indexed because the cost of expanding memory for string storage is higher than the cost of adding a topic. On the other hand, for uint256 parameters, it is the opposite scenario, where it is more efficient to declare them as non-indexed. Adding a topic has a higher cost compared to directly storing the uint256 value in the data part of the event log.

```solidity
// 1740 gas
function anonLog() public {
    emit AnonymousLog(1, 2, 3);
}

// 1817 gas
function logNum() public {
    emit LogNum(1, 2, 3);
}

// 2121 gas
function logNumIndexed() public {
    emit LogNumIndexed(1, 2, 3);
}

// 2286 gas
function logStringIndexed() public {
    emit LogStringIndexed("Hello", "World", "!");
}

// 3463 gas
function logString() public {
    emit LogString("Hello", "World", "!");
}
```

### forge commands

- `forge test --mc EventsTest -vvvv` - run gas tests

### References

- https://docs.soliditylang.org/en/develop/abi-spec.html#abi-events

**[⬆ back to top](#optimizations)**
