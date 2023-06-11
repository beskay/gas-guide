## Storage

### Basics

Contract storage is a key-value store that maps 256-bit words to 256-bit words. All locations in storage are well-defined initially as zero. All data, except for dynamically sized arrays and mappings, is laid out one after another in storage starting from slot 0.

![storage](images/storage.png)

Multiple variables can be stored in the same slot if they fit. This is called variable packing:

- The first item in a storage slot is stored lower-order aligned (it uses the lowest available bits)
- Value types use only as many bytes as are necessary to store them (e.g. uint8 uses 1 byte)
- If a value type does not fit the remaining part of a storage slot, it is stored in the next slot
- Structs and array data always start a new slot and their items are packed tightly according to these rules
- Items following struct or array data also start a new storage slot

Dynamically sized arrays and mappings cannot be stored in between the other state variables:

- The length of an array is stored in slot `x` according to the rules above, while the data of the array starts at `slot(keccak256(x))`
- Mappings reserve a storage slot `x` according to the rules above, but there is no data stored in it. The storage slot is used to compute the location of the value in the mapping: `slot(keccak(key, x))`

We can inspect the storage of smart contracts with `forge inspect MyContract storage` or, when slither is installed, with `slither <path_to_contract> --print variable-order`. Run `forge inspect StorageLayout storage` for an example.

### Gas costs related to storage

The opcodes related to storage are `SLOAD` and `SSTORE`. Storage reads and writes are, besides contract creation, the most expensive operations in the EVM. Both have a minimum cost of 100 gas and an additional cost depending on the state of the storage slot.

![storage gas costs](images/storage_opcodes.png)

**Storage writes**

- zero -> nonzero: 20k gas, if first time access additional 2.1k gas

  > G_coldsload + G_sset= 20k gas + 2.1k gas

- nonzero -> nonzero: 5k gas

  > G_coldsload + G_sreset = 2900 gas + 2100 gas

- nonzero -> zero: refund

  > Refund 4800 gas per cleared storage var (since EIP-3529)
  > Refunds are capped to total_gas_used / 5, to get a refund of 4800 gas the transaction needs to use 24k gas at minimum

- zero -> zero: 2.2k gas

  > G_coldsload + G_warmaccess = 2100 gas + 100 gas

**Storage reads**

- Storage read (cold): 2.1k gas

  > G_coldsload = 2100 gas

- Storage read (warm): 100 gas

  > G_warmaccess = 100 gas

**Accesslist**

Since EIP-2930 it is possible to specify a list of addresses and storage keys which will be touched during the transaction execution. When an address or storage slot is present in that list, it is called "warm", otherwise it is "cold". This allows to reduce the gas costs for storage reads and writes as seen in the image above.

Run `forge test --mc StorageTest -vvvv` to see the gas costs in detail.

## Memory

### Basics

Contract memory is a byte array, where data can be stored in 32 bytes or 1 byte chunks and read in 32 bytes chunks. Elements in memory always occupy multiples of 32 bytes, even if the data uses less bytes. Unlike with contract storage, there is no variable packing. Memory is temporary and only exists during the execution of a transaction.

![memory](images/memory.png)

Solidity reserves four 32-byte slots, with specific byte ranges (inclusive of endpoints) being used as follows:

- `0x00` to `0x3f`: scratch space for hashing method
- `0x40` to `0x5f`: free memory pointer (currently allocated memory size)
- `0x60` to `0x7f`: zero slot

The zero slot is used as initial value for dynamic memory arrays and should never be written to. This also means that the free memory pointer points to `0x80` initially. Memory is never freed, so the free memory pointer only increases.

> Sidenote: The bytecode sequence `6080604052` you see at the start of the runtime bytecode of almost every contract is the initialization of the free memory pointer. It is the bytecode for `mstore(0x40, 0x80)`, which stores the value `0x80` at memory location `0x40`.

### Gas costs related to memory

The opcodes related to memory are:

![memory_opcodes](images/memory_opcodes.png)

All three opcodes have a static gas cost of 3, and a dynamic gas cost related to the memory expansion cost.

![memorycost](images/memorycost.png)

#### Memory expansion

If you write to, or read from, a memory location that is not yet allocated, the memory is expanded in 32 byte chunks. The cost of this expansion is:

![mem_equation](images/mem_equation.png)

where `a` is the size of the memory.

From the Yellowpaper:

> Note also that C_mem is the memory cost function (the expansion function being the difference between the cost before
> and after). It is a polynomial, with the higher-order coefficient divided and floored, and thus linear up to 704B of memory
> used, after which it costs substantially more.

This is also referred to as memory explosion, since the cost of expanding memory is not linear, but quadratic.

Run `forge test --mc MemoryTest -vvvv` to see the gas costs and the costs of memory expansion in detail.

## Calldata

### Basics

Calldata is very similar to memory, but it is read-only. Calldata can only be used in external function calls, and is used to pass arguments to functions. The Yellowpaper defines the calldata as

> an unlimited size byte array specifying the input data of the message call

Calldata is assumed to be in a format defined by the abi specification, which means padded to multiples of 32 bytes.

<!-- ![calldata](images/calldata.png) -->

### Gas costs related to calldata

The opcodes related to calldata are:

![calldata_opcodes](images/calldata_opcodes.png)

`CALLDATALOAD` and `CALLDATASCOPY` have a static gas cost of 3, while `CALLDATASIZE` has a static gas cost of 2. There is no dynamic cost in contrast to memory.

![calldatacost](images/calldatacost.png)

A byte of calldata costs either 4 gas (if it is zero) or 16 gas (if it is any other value). The gas cost for non-zero bytes was reduced from 68 to 16 with EIP-2028, to increase the scalability of L2's.

**While calldata is the cheapest resource on mainnet, it is the most expensive one on Layer 2s.** This is because rollups pay cheap layer-2 fees for execution and storage, but expensive layer-1 fees to publish their data on Ethereum.

The calldata costs will be significantly reduced with proto-danksharding (EIP-4844). For now, there are calldata compression techniques that can be used to reduce the gas costs, see `src/CalldataCompression.sol`.

To see the gas costs yourself, follow the instructions in `script/Calldata.s.sol`.

## References

- [Ethereum Yellowpaper](https://ethereum.github.io/yellowpaper/paper.pdf)
- [Ethereum EVM Illustrated (2018)](https://takenobu-hs.github.io/downloads/ethereum_evm_illustrated.pdf)

A great resource to estimate gas costs of various opcodes is [evm.codes](https://evm.codes/)

### Storage

- [Solidity Internals: Layout in Storage](https://docs.soliditylang.org/en/latest/internals/layout_in_storage.html)
- [Understanding Ethereum Smart Contract Storage](https://programtheblockchain.com/posts/2018/03/09/understanding-ethereum-smart-contract-storage/)
- [EVM Deep Dives: The Path to Shadowy 3EA](https://noxx.substack.com/p/evm-deep-dives-the-path-to-shadowy-3ea?s=r)
- [Diving into the Ethereum VM: The Hidden Costs of Arrays](https://medium.com/@hayeah/diving-into-the-ethereum-vm-the-hidden-costs-of-arrays-28e119f04a9b)
- [EIP-3529](https://eips.ethereum.org/EIPS/eip-3529)
- [EIP-2930](https://eips.ethereum.org/EIPS/eip-2930)
- [evm.storage](https://evm.storage/)

### Memory

- [Solidity Internals: Layout in Memory](https://docs.soliditylang.org/en/latest/internals/layout_in_memory.html)
- [EVM Deep Dives: The Path to Shadowy D6B](https://noxx.substack.com/p/evm-deep-dives-the-path-to-shadowy-d6b?s=r)

### Calldata

- [Solidity Internals: Layout in Calldata](https://docs.soliditylang.org/en/latest/internals/layout_in_calldata.html)
- [Solidity ABI Specification](https://docs.soliditylang.org/en/latest/abi-spec.html)
- [EIP-4844](https://eips.ethereum.org/EIPS/eip-4844)
- [EIP-2028](https://eips.ethereum.org/EIPS/eip-2028)
- [Short ABI - Ethereum Developers](https://ethereum.org/en/developers/tutorials/short-abi/)
- [Rollup Calldata Compression](https://l2fees.info/blog/rollup-calldata-compression)
