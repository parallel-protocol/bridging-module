# Context

This document refers the information for auditing the `BridgeableToken` contract.

## File Scope

| File                                                                                                                                                       |      [nSLOC](#nowhere "(nSLOC, nLines, Lines)")      | Description                                                                                                        | Libraries                                                                                                                                                                                                                 |
| :--------------------------------------------------------------------------------------------------------------------------------------------------------- | :--------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| _Contracts (3)_                                                                                                                                            |
| [contracts/tokens/BridgeableToken.sol](https://gitlab.com/murphy-labs/parallel/bridging-module/-/blob/main/contracts/tokens/BridgeableToken.sol)           | [279](#nowhere "(nSLOC:279, nLines:506, Lines:534)") | Main contract that sends and receives LayerZero messages, handling the minting and burning of the principal token. | [`@openzeppelin/*`](https://openzeppelin.com/contracts/) [`@layerzerolabs/lz-evm-oapp-v2/*`](https://github.com/LayerZero-Labs/LayerZero-v2/tree/417cbb9eb68a4f678490d18728973c8c99f3f017/packages/layerzero-v2/evm/oapp) |
| [contracts/libraries/MathLib.sol](https://gitlab.com/murphy-labs/parallel/bridging-module/-/blob/main/contracts/libraries/MathLib.sol)                     |   [13](#nowhere "(nSLOC:13, nLines:22, Lines:22)")   | Maths library helper                                                                                               | -                                                                                                                                                                                                                         |
| [contracts/libraries/PercentageMathLib.sol](https://gitlab.com/murphy-labs/parallel/bridging-module/-/blob/main/contracts/libraries/PercentageMathLib.sol) |   [24](#nowhere "(nSLOC:24, nLines:48, Lines:48)")   | Library to handle percentage maths                                                                                 | -                                                                                                                                                                                                                         |

## Out of scope

All other files in the repository are out of scope for this audit.

## External imports

- **@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OApp.sol**
  - [contracts/tokens/BridgeableToken.sol#L1](https://gitlab.com/murphy-labs/parallel/bridging-module/-/blob/main/contracts/tokens/BridgeableToken.sol#L1)
- **@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFT.sol**
  - [contracts/tokens/BridgeableToken.sol#L1](https://gitlab.com/murphy-labs/parallel/bridging-module/-/blob/main/contracts/tokens/BridgeableToken.sol#L1)
- **@layerzerolabs/lz-evm-oapp-v2/contracts/oft/interfaces/IOFT.sol**
  - [contracts/tokens/BridgeableToken.sol#L1](https://gitlab.com/murphy-labs/parallel/bridging-module/-/blob/main/contracts/tokens/BridgeableToken.sol#L1)
- **@layerzerolabs/lz-evm-oapp-v2/contracts/oft/libs/OFTMsgCodec.sol**
  - [contracts/tokens/BridgeableToken.sol#L1](https://gitlab.com/murphy-labs/parallel/bridging-module/-/blob/main/contracts/tokens/BridgeableToken.sol#L1)
- **@openzeppelin/contracts/access/Ownable.sol**
  - [contracts/tokens/BridgeableToken.sol#L1](https://gitlab.com/murphy-labs/parallel/bridging-module/-/blob/main/contracts/tokens/BridgeableToken.sol#L1)
- **@openzeppelin/contracts/token/ERC20/IERC20.sol**
  - [contracts/tokens/BridgeableToken.sol#L1](https://gitlab.com/murphy-labs/parallel/bridging-module/-/blob/main/contracts/tokens/BridgeableToken.sol#L1)
- **@openzeppelin/contracts/utils/Pausable.sol**
  - [contracts/tokens/BridgeableToken.sol#L1](https://gitlab.com/murphy-labs/parallel/bridging-module/-/blob/main/contracts/tokens/BridgeableToken.sol#L1)
- **@openzeppelin/contracts/utils/ReentrancyGuard.sol**
  - [contracts/tokens/BridgeableToken.sol#L1](https://gitlab.com/murphy-labs/parallel/bridging-module/-/blob/main/contracts/tokens/BridgeableToken.sol#L1)

## Additional context

Please read the [BridgeableToken README](./README.md) for more context.

## Scoping Details

```
- If you have a public code repo, please share it here: n/a
- How many contracts are in scope?: 3
- Total SLoC for these contracts?:  316
- How many external imports are there?: 8
- How many separate interfaces and struct definitions are there for the contracts within scope?: 1 structs, 1 interfaces
- Does most of your code generally use composition or inheritance?: inheritance
- How many external calls?: 2
- What is the overall line coverage percentage provided by your tests?: n/a revert due to layerzero helper
- Is there a need to understand a separate part of the codebase / get context in order to audit this part of the protocol? n/a
- Please describe required context: Please read the README for the BridgeableToken.
- Does it use an oracle?: No
- Does the token conform to the ERC20 standard?: Yes
- Are there any novel or unique curve logic or mathematical models?: No
- Does it use a timelock function?: No
- Is it an NFT?: No
- Does it have an AMM?: No
- Is it a fork of a popular project?: No
- Does it use rollups?: No
- Is it multi-chain?: Yes
- Does it use a side-chain?: No
```

# Tests

The contract is tested using the `foundry` framework. The tests are located in the `tests` folder.

Make sure to have [foundry](https://book.getfoundry.sh/getting-started/installation) install.

### Run tests

There are 2 types of tests:

- Classic tests (Units/Integrations) :

```bash
npm run test
```

- Invariant tests:

```bash
npm run test:invariant
```

## Running Static Analysis

The root folder contains a slither.config.json file that can be used to run static analysis on the project.

To run the static analysis, you can use the following commands:

```bash
pip3 install slither-analyzer
pip3 install solc-select
solc-select install 0.8.22
solc-select use 0.8.22
slither .
```

We already know that Slither will report the following points:

```bash
Reentrancy in BridgeableToken._lzReceive(Origin,bytes32,bytes,address,bytes) (contracts/tokens/BridgeableToken.sol#333-354):
        External calls:
        - (amountReceived,oftReceived,feeAmount) = _credit(toAddress,_toLD(_message.amountSD()),_origin.srcEid,feeApplicable) (contracts/tokens/BridgeableToken.sol#350-351)
                - IERC20MintableAndBurnable(address(principalToken)).mint(feesRecipient,feeAmount) (contracts/tokens/BridgeableToken.sol#427)
                - IERC20MintableAndBurnable(address(principalToken)).mint(_to,amountReceived) (contracts/tokens/BridgeableToken.sol#430)
        Event emitted after the call(s):
        - EventsLib.BridgeableTokenReceived(_guid,_origin.srcEid,toAddress,amountReceived,oftReceived,feeAmount) (contracts/tokens/BridgeableToken.sol#353)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities-3

PercentageMathLib.percentDiv(uint256,uint256) (contracts/libraries/PercentageMathLib.sol#32-47) is never used and should be removed
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#dead-code
```

- The reentrancy issue is a false positive. The contract is using the `Pausable` and `ReentrancyGuard` from OpenZeppelin. The reentrancy issue is not exploitable in this context.
- The `PercentageMathLib.percentDiv` is a helper function that is not used in the contract but is kept for future use.
