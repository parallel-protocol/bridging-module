// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

/// @title EventsLib
/// @author Cooper Labs
/// @custom:contact security@cooperlabs.xyz
/// @notice Library exposing all errors link to the bridging module.
library EventsLib {
    /// @notice Event emitted when the isolate mode is toggled by the Owner.
    /// @param isolateMode the flag to indicate if the isolate mode is enabled.
    event IsolateModeToggled(bool isolateMode);

    /// @notice Event emitted when a new daily credit limit is set by the Owner.
    /// @param dailyCreditLimit the new daily credit limit.
    event DailyCreditLimitSet(uint256 dailyCreditLimit);

    /// @notice Event emitted when a new daily debit limit is set by the Owner.
    /// @param dailyDebitLimit the new daily debit limit.
    event DailyDebitLimitSet(uint256 dailyDebitLimit);

    /// @notice Event emitted when a new global credit limit is set by the Owner.
    /// @param globalCreditLimit the new global credit limit.
    event GlobalCreditLimitSet(uint256 globalCreditLimit);

    /// @notice Event emitted when a new global debit limit is set by the Owner.
    /// @param globalDebitLimit the new global debit limit.
    event GlobalDebitLimitSet(uint256 globalDebitLimit);

    /// @notice Event emitted when the fees rate is set by the Owner.
    /// @param feesRate the new fees rate.
    event FeesRateSet(uint16 feesRate);

    /// @notice Event emitted when the fees recipient is set by the Owner.
    /// @param feesRecipient the new fees recipient address.
    event FeesRecipientSet(address feesRecipient);

    /// @notice Event emitted when tokens are sent from the src chain to the dst chain.
    /// @param guid the GUID of the OFT message.
    /// @param dstEid the Eid code of the destination chain.
    /// @param from the Address of the token sender.
    /// @param to the Address that will receive the tokens.
    /// @param nativeFeeAmount the amount of the fees in native token.
    /// @param isPrincipalTokenSent the flag to indicate if the principal tokens are burned or OFTs.
    /// @param amountSent the amount sent.
    /// @param amountReceive the amount expected to receive on the destination chain.
    event BridgeableTokenSent(
        bytes32 guid,
        uint32 indexed dstEid,
        address indexed from,
        address indexed to,
        uint256 nativeFeeAmount,
        bool isPrincipalTokenSent,
        uint256 amountSent,
        uint256 amountReceive
    );

    /// @notice Event emitted when the caller send principal tokens.
    /// @param to the Address of the token reciever.
    /// @param totalAmount the total amount of tokens sent.
    /// @param amountSent the amount sent from the locked balance.
    /// @param amountMinted the amount minted.
    event PrincipalTokenCredited(address to, uint256 totalAmount, uint256 amountSent, uint256 amountMinted);

    /// @notice Event emitted when the caller debits principal tokens.
    /// @param to the Address of the token reciever.
    /// @param totalAmount the total amount of tokens debited.
    /// @param amountLocked the amount debited from the locked balance.
    /// @param amountBurned the amount burned.
    event PrincipalTokenDebited(address to, uint256 totalAmount, uint256 amountLocked, uint256 amountBurned);

    /// @notice Event emitted when tokens are received from the src chain to the dst chain.
    /// @param guid the GUID of the OFT message.
    /// @param srcEid the Eid code of the source chain.
    /// @param from the Address of the token sender.
    /// @param to the Address of the token receiver.
    /// @param amountReceived the amount of tokens received.
    /// @param oftReceived the amount of OFT received.
    /// @param feeAmount the amount of the fees.
    event BridgeableTokenReceived(
        bytes32 guid,
        uint32 indexed srcEid,
        address indexed from,
        address indexed to,
        uint256 amountReceived,
        uint256 oftReceived,
        uint256 feeAmount
    );

    /// @notice Event emitted when the caller swap OFT for principal tokens.
    /// @param caller Address of the caller.
    /// @param to Address of the receiver.
    /// @param amountSwapped Amount of OFT swapped.
    /// @param principalTokenAmountReceived Amount of principal tokens received.
    /// @param feeAmount Amount of fees in principal token.
    event OFTSwapped(
        address caller,
        address to,
        uint256 amountSwapped,
        uint256 principalTokenAmountReceived,
        uint256 feeAmount
    );

    /// @notice Event emitted when a new BridgeableToken is created.
    /// @dev Used to init the indexer.
    /// @param initialPrincipalTokenAmountMinted The initial amount of principal tokens minted.
    /// @param initialCreditDebitBalance The initial credit debit balance.
    event BridgeableTokenCreated(uint256 initialPrincipalTokenAmountMinted, int256 initialCreditDebitBalance);
}
