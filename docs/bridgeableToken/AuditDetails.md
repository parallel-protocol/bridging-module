# Context

This document refers the information for auditing the `BridgeableToken` contract.

## File Scope

| File                                                                                                                                                  |      [nSLOC](#nowhere "(nSLOC, nLines, Lines)")      | Description                                                                                                       | Libraries                                                                                                                                                                                                                                                                                                                       |
| :---------------------------------------------------------------------------------------------------------------------------------------------------- | :--------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| _Contracts (3)_                                                                                                                                       |
| [contracts/tokens/BridgeableToken.sol](https://github.com/parallel-protocol/bridging-module/blob/main/contracts/tokens/BridgeableToken.sol)           | [326](#nowhere "(nSLOC:326, nLines:587, Lines:623)") | Main contract that sends and receives LayerZero messages, handling the credit/debit logic of the principal token. | [`@openzeppelin/*`](https://openzeppelin.com/contracts/) [`@layerzerolabs/lz-evm-oapp-v2/evm/oapp`](https://github.com/LayerZero-Labs/LayerZero-v2/tree/417cbb9eb68a4f678490d18728973c8c99f3f017/packages/layerzero-v2/evm/oapp) [`layerZero/*`](https://github.com/parallel-protocol/prl-token/blob/main/contracts/layerZero/) |
| [contracts/libraries/MathLib.sol](https://github.com/parallel-protocol/bridging-module/blob/main/contracts/libraries/MathLib.sol)                     |   [18](#nowhere "(nSLOC:18, nLines:28, Lines:28)")   | Maths library helper                                                                                              | -                                                                                                                                                                                                                                                                                                                               |
| [contracts/libraries/PercentageMathLib.sol](https://github.com/parallel-protocol/bridging-module/blob/main/contracts/libraries/PercentageMathLib.sol) |   [24](#nowhere "(nSLOC:24, nLines:48, Lines:48)")   | Library to handle percentage maths                                                                                | -                                                                                                                                                                                                                                                                                                                               |

## Out of scope

All other files in the repository are out of scope for this audit.

## External imports

- **@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OApp.sol**
  - [contracts/tokens/BridgeableToken.sol](https://github.com/parallel-protocol/bridging-module/blob/main/contracts/tokens/BridgeableToken.sol)
- **@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFT.sol**
  - [contracts/tokens/BridgeableToken.sol](https://github.com/parallel-protocol/bridging-module/blob/main/contracts/tokens/BridgeableToken.sol)
- **@layerzerolabs/lz-evm-oapp-v2/contracts/oft/interfaces/IOFT.sol**
  - [contracts/tokens/BridgeableToken.sol](https://github.com/parallel-protocol/bridging-module/blob/main/contracts/tokens/BridgeableToken.sol)
- **@layerzerolabs/lz-evm-oapp-v2/contracts/oft/libs/OFTMsgCodec.sol**
  - [contracts/tokens/BridgeableToken.sol](https://github.com/parallel-protocol/bridging-module/blob/main/contracts/tokens/BridgeableToken.sol)
- **@openzeppelin/contracts/access/Ownable.sol**
  - [contracts/tokens/BridgeableToken.sol](https://github.com/parallel-protocol/bridging-module/blob/main/contracts/tokens/BridgeableToken.sol)
- **@openzeppelin/contracts/token/ERC20/IERC20.sol**
  - [contracts/tokens/BridgeableToken.sol](https://github.com/parallel-protocol/bridging-module/blob/main/contracts/tokens/BridgeableToken.sol)
- **@openzeppelin/contracts/utils/Pausable.sol**
  - [contracts/tokens/BridgeableToken.sol](https://github.com/parallel-protocol/bridging-module/blob/main/contracts/tokens/BridgeableToken.sol)
- **@openzeppelin/contracts/utils/ReentrancyGuard.sol**
  - [contracts/tokens/BridgeableToken.sol](https://github.com/parallel-protocol/bridging-module/blob/main/contracts/tokens/BridgeableToken.sol)

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

## Run tests

There are 2 types of tests:

- Classic tests (Units/Integrations) :

```bash
bun run test
```

- Invariant tests:

```bash
bun run test:invariant
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

## Known issues accepted by the team

### Fees can be bypassed using a middleware chain that has met the mint limits.

The bridge charges fees only when principal tokens (PTs) are consumed on the source chain and PTs are dispersed on the destination chain. If the mint limits are met on a chain, OFT tokens are instead minted, which are meant to be placeholder tokens that can later be swapped out for PTs. If the bridge mints or burns OFTs, no fees are charged.

This creates a scenario where users can bypass the fee mechanism of the bridge by cleverly timing their bridging activities. This is done in two steps (assuming chain A is the source chain, chain B is the middleware chain, and chain C is the destination chain):

1. Bridge PTs from chain A to OFTs on chain B. This can be achieved by backrunning a large bridge transfer that maxes out the mint limit, resulting in the user being minted OFT tokens instead.
2. Bridge OFTs from chain B to PTs on chain C. The user will not be charged any fees for this transfer because the bridge burned OFTs on chain B and not PTs.

This is a known issue, and we accept it because while users may skip the contract fees, they will still pay the LayerZero bridge fees twice, which could result in a higher cost than the fees of the bridgeable token.

### Fees are charged on OFT token bridging if limits are reached

When the credit limits are met, users get minted OFT tokens when
bridging which can be swapped for principal tokens at a later stage.
However, to allow unsatisfied users to roll back their bridging
transaction, the protocol does not charge any fees if OFT tokens are
being bridged for principal tokens. This way users can revert their
transaction at no fee cost if they are minted OFT tokens.

However, the issue is that this fee-less bridge rollback is not always
possible. This happens when the credit limits are met on the source
chain as well. Consider the following scenario:

1. Alice wants to bridge principal tokens from chainA to chain B.
   Alice calls send on chainA and her principal tokens are locked
   in the bridge.
2. In chainB, the mint limit has already been met. So Alice gets
   minted OFT tokens instead.
3. Alice is unhappy and wants to revert her transaction. She calls
   send on chainB with isPrincipalTokenSent set to false.
4. In chainA, the mint limit has already been met. Thus Alice gets
   minted OFT tokens on chainA as well.

In the scenario above, Alice is unable to roll back her bridging
transaction for no fees. She can call swapLzTokenToPrincipalToken to
swap the OFT tokens for principal tokens on chainA, but this will
charge her fees.

This issue may happen by chance but can also be triggered by a
malicious user. The malicious user can frontrun the transaction and fill
the limits in order for the user who will then receive OFT tokens which
they have to pay a fee for if they want back the principal tokens.

### Bridging will not be possible if all chains are set to isolateMode

Due to how `isolateMode` works, if all chains are set to this mode and
`_config.initialCreditDebitBalance` is also 0 on all chains, bridging will
be impossible. We accept this issue because the bridgeable token is not
meant to be used in this mode on all chains.

### Centralization risk introduced by emergencyRescue function

The bridge is meant to lock most principal tokens.
This means the amount of tokens held by the contract will in most
cases result in a large amount of tokens being stored on the bridge.
The emergency withdrawal function allows the owner to withdraw the
total amount without any restrictions.
This makes the risk of private key compromise even more severe.
Furthermore, when emergencyWithdraw is called, the tokens are sent
out and are unable to unlock during credit transactions so the contract
is forced to mint out tokens instead and raise the
`principalTokenAmountMinted`. Thus the protocol effectively is indebted
to the admin until they return the tokens only after which the
`principalTokenAmountMinted` can return to 0 with debits.

We accept this issue as the contract owner will be an AccessManager contract from OpenZeppelin standard.
We had to use the `Ownable` contract from OpenZeppelin to comply with LayerZero's OFT contract.

## Audit amendments

Here are the logic/code changes made since the last audit:

- Refactored of `BridgeableToken` contract :
  - The contract will now lock the principal token instead of burning them by default.
  - The contract will only mint new principal tokens if it doesn't have enough of them to credit the user.
  - When new principal tokens are minted, the contract will track the amount minted and will burn future principal tokens that will be bridged out until the amount minted is 0.
  - Add an `emergencyWithdraw` function to allow owner to withdraw principal tokens in the contract in case of an emergency.
  - Renamed `mint` and `burn` related variables/functions to `credit` and `debit` to better reflect the logic of the contract.
