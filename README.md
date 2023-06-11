# Gas optimization mentorship

A comprehensive guide to teach you about gas optimization techniques.

This mentorship is aimed at developers who are already familiar with Solidity and want to learn how to write more gas efficient smart contracts.

## Content

- [Introduction](INTRO.md)
  - General overview of gas in Ethereum
- [EVM Basics](BASICS.md)
  - Necessary background knowledge about the EVM (Storage, Memory, Calldata)
- [Gas optimization techniques](OPTIMIZATIONS.md)
  - Extensive collection of gas optimization techniques

We will use Foundry to look into certain code snippets in detail. Most gas optimization examples have a corresponding source and test file to debug/inspect in detail.

Important commands we will use throughout this mentorship:

- `forge test --mc <contract_name> -vvvv` // running tests, showing stack traces
- `forge inspect src/Counter.sol:Counter ir-optimized` // show optimized yul
- `forge inspect src/Counter.sol:Counter methods` // show function selectors
- `forge debug --debug src/Counter.sol --sig "incrementUnchecked()"` // debug functions
