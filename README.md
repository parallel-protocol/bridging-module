# Overview

This repository contains the source code for contracts and testing suites for all of Parallel's omnichain-related contracts. Documentation for each main contract can be found in the [/docs](./docs) folder.

## Repository Structure

- [Broadcast](./broadcast) folder contains Foundry transactions executed by scripts.
- [Contracts](./contracts) folder contains contracts source code.
- [Deploy](./deploy) folder contains hardhat deployment scripts.
- [Deployments](./deployments) folder contains info of contracts deployed per network.
- [Docs](./docs) folder contains all documentation related to main contracts.
- [Script](./scripts) folder contains Foundry scripts to interact with onchain contracts.
- [Test](./test) folder contains all tests related to the contracts with mocks and settings.
- [Utils](./utils) folder contains helper functions.

## Contracts

The [`BridgeableToken.sol`](./contracts/tokens/BridgeableToken.sol) allow a principal token to be bridgeable by leveraging on [LayerZero's OFT standard](https://docs.layerzero.network/v2/home/protocol/contract-standards#oft) with custom credit/debit limits. See the [BridgeableToken documentation](./docs/bridgeableToken/README.md) for more details.

## Getting Started

### Foundry

Foundry is used for testing and scripting. To
[Install foundry follow the instructions.](https://book.getfoundry.sh/getting-started/installation)

### Install js dependencies

```bash
bun i
```

### Fill the `.env` file with your data

The Foundry script relies solely on the PRIVATE_KEY. The MNEMONIC is used on the Hardhat side and will override the PRIVATE_KEY if it is defined.

```bash
MNEMONIC=
PRIVATE_KEY=0x...
ALCHEMY_API_KEY=
```

### Compile contracts

```bash
bun run compile
```

### Run tests

There are 2 types of tests:

- Classic tests (Units/Integrations) :

```bash
bun run test
```

- Invariant tests:

```bash
bun run test:invariant
```

You will find other useful commands in the [package.json](./package.json) file.

## Licences

All contracts is under the `MIT` License, see [`LICENSE`](./LICENSE).
