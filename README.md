# Gas optimization guide

A comprehensive guide to teach you about gas optimization patterns.

This guide is aimed at developers who are already familiar with Solidity and want to learn how to write more gas efficient smart contracts.

## Content

- [Introduction](INTRO.md)
  - General overview of gas in Ethereum
- [EVM Basics](BASICS.md)
  - Necessary background knowledge about the EVM (i.e. data locations)
- [Gas optimization techniques](OPTIMIZATIONS.md)
  - Extensive collection of gas optimization techniques

You can use Foundry to look into certain code snippets in detail. Most gas optimization examples have a corresponding source and test file to debug/inspect further.

Useful forge commands for inspecting and debugging contracts in this repository:

- `forge test --mc <contract_name> -vvvv` // run tests and show stack traces
- `forge inspect <Contract> ir-optimized` // show optimized Yul
- `forge inspect <Contract> methods` // show function selectors
- `forge debug --debug <Contract> --sig "foo()"` // debug functions

## Practice

Practice by completing the challenges in [`./src/practice/`](./src/practice/). The suggested order to complete them is:

1. [ArraySum](./src/practice/ArraySum.sol)
2. [Airdrop](./src/practice/Airdrop.sol)
3. [BadERC20](./src/practice/BadERC20.sol)
4. [BadERC721](./src/practice/BadERC721.sol)

`ArraySum` is an example contract where you can apply various gas optimization patterns. The required gas goal is achieveable by just using the patterns described in the [Gas optimization techniques](OPTIMIZATIONS.md) section.

`Airdrop`, `BadERC20` and `BadERC721` are inefficient contracts that have been deployed onchain. Try to improve them as much as you can. You can use the following test cases to track your progress:

- `forge test --mc ArraySumTest`
- `forge test --mc AirdropTest`
- `forge test --mc BadERC20Test -vv`
- `forge test --mc BadERC721Test -vv`

### Notable repositories to use

- [solmate](https://github.com/transmissions11/solmate)
- [solady](https://github.com/Vectorized/solady/tree/main)
- [ERC721A](https://github.com/chiru-labs/ERC721A/tree/main)
- [ERC721B](https://github.com/beskay/ERC721B)
