# BridgeableToken

## Overview

[BridgeableToken.sol](contracts/BridgeableToken.sol) allows an already deployed ERC-20 token to be bridgeable by leveraging [LayerZero's OFT standard](https://docs.layerzero.network/v2/home/protocol/contract-standards#oft).

## Key Features

The key features of `BridgeableToken` are:

- Ability to lock/burn principal tokens (named `XXX`) and send a message to LayerZero to credit the mirrored token on another chain.
- Ability to transfer locked/mint principal tokens by receiving a message from LayerZero from the mirrored BridgeableToken contract on another chain.
- Ability to cap the principal token amount to credit and debit (per day and globally). Since tx on the receiving chains must not revert, when the credit limit is reached, the user will receive OFT tokens (named `lz-XXX`) instead of principal tokens.
- Ability to swap OFT tokens to principal tokens if credit limits are not reached.
- Track the amount of principal tokens minted during credit. These tokens will be burned back when users send messages to the other chain.

### High level Design

![BridgeableToken HLD](./assets/bridgeableToken-HLD.png)

## Technical Details

### LayerZero OFT standard

The OFT standard from LayerZero allows fungible tokens to be transferred across multiple blockchains without asset wrapping or middlechains. The BridgeableToken contract is designed to comply with this standard to mint/burn the OFT tokens. More details about the OFT standard can be found [here](https://docs.layerzero.network/v2/home/protocol/contract-standards#oft).

### Why do we need an OFT token ?

When the contract receives a message from LayerZero to credit principal tokens on its chain to the receiver, it must not revert. Due to the credit limits, we still have to credit the user with something. This is why we mint OFT tokens. The user can then swap these OFT tokens for principal tokens if the limit is not reached.

### Receiving Credit Messages from LayerZero

When the contract receives a message from LayerZero, it will check its principal token balance and transfer them until the amount to credit is reached, however if additional principal token are needed, the contract will mint new ones and track the amount minted. Depending on the credit limits, the receiver will be credited with principal tokens and/or OFT tokens.

### Sending Messages to LayerZero

Users can send principal tokens or OFT tokens to a receiver address on another chain by calling the `send` function. A check regarding debit limits and isIsolateMode is performed before sending the message to LayerZero. If any check fails, the function will revert. The user's tokens will be in priority burned if the contract has its `principalTokenAmountMinted` variable greater than 0. As soon as the contract has no more principal token to burn, it will lock the principal token for later receiving messages.

### Swap OFT tokens to principal tokens

As users can receive OFT tokens instead of principal tokens when one of the credit limits is reached, the contract provides a `swapLzTokenToPrincipalToken` function to swap these OFT tokens for principal tokens according to the limits.

### EmergencyWithdraw

A `emergencyWithdraw` function exists to allow the owner to rescue any locked principaltokens in the contract in case of an emergency.

Only the **Owner** may call emergencyWithdraw

### Pause

A `pause` function exists to prevent new `send()` calls from being executed. This is useful in the event of a bug or security vulnerability.

Only the **Owner** may call pause

### Unpause

An `unpause` function exists to unpaused the contract.

Only the **Owner** may call unpause

### IsolateMode

A `toggleIsolateMode` function exists to toggle the `isIsolateMode` variable.
This variable is used to prevent the contract to debit more principal token than what it has credited.

Only the **Owner** may call toggleIsolateMode

### Principal token credit/debit limits

Daily and global credit/debit limits on the principal token:

- `dailyCreditLimit` : Maximum amount of principal tokens that can be credited in a day.
- `dailyDebitLimit` : Maximum amount of principal tokens that can be debited in a day.
- `globalCreditLimit` : Maximum amount of principal tokens that can be credited globally.
- `globalDebitLimit` : Maximum amount of principal tokens that can be debited globally.

When a credit limit is reached, the contract will credit the user with OFT tokens instead of principal tokens. When a debit limit is reached, the contract will revert future send requests for principal tokens.

Only the **Owner** may update the daily and global credit/debit limits.

## Sample use cases

### User scenario 1

In this scenario, no limit is reached. The user sending 100 principal tokens.
The contract will first check if its `principalTokenAmountMinted` variable is greater than 0.
If it is, it will burn the bridged amount until its value is 0, then it will transfer the amount left of principal tokens to itself (for locking) and then send a message to LayerZero to credit the receiver with 100 principal tokens on the other chain.
![Scenario 1](./assets/scenario-1.png)

### User scenario 2

In this scenario, no limit is reached. The user sending 100 OFT tokens.
The contract will burn 100 OFT tokens and send a message to LayerZero to credit the receiver with 100 principal tokens on the other chain.

![Scenario 2](./assets/scenario-2.png)

### User scenario 3

In this scenario, a credit limit is reached. The user sending 100 principal tokens.
The contract will transfer the amount left of principal tokens to itself (for locking) and send a message to LayerZero to credit the receiver with 100 principal tokens, but as the credit limit is reached, the user will receive OFT tokens lz-XXX on the other chain.

![Scenario 3](./assets/scenario-3.png)

## Deployment

Check the [DeployedAddresses.md](./DeployedAddresses.md) file for the deployed addresses on different networks.

## Documentation for audit

For more details on the contract, refer to the [Audit details](./AuditDetails.md).
