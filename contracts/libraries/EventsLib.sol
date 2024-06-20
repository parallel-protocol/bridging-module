// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

/// @title EventsLib
/// @author Murphyy Labs
/// @custom:contact security@murphylabs.io
/// @notice Library exposing all errors link to the bridging module.
library EventsLib {
    /// @notice Event emitted when the isolate mode is toggled by the Owner.
    /// @param isolateMode the flag to indicate if the isolate mode is enabled.
    event IsolateModeToggled(bool isolateMode);

    /// @notice Event emitted when the mintable daily limit is set by the Owner.
    /// @param mintableDailyLimit the new mintable daily limit.
    event MintableDailyLimitSet(uint256 mintableDailyLimit);

    /// @notice Event emitted when the burnable daily limit is set by the Owner.
    /// @param burnableDailyLimit the new burnable daily limit.
    event BurnableDailyLimitSet(uint256 burnableDailyLimit);

    /// @notice Event emitted when the global mint limit is set by the Owner.
    /// @param globalMintLimit the new global mint limit.
    event GlobalMintLimitSet(uint256 globalMintLimit);

    /// @notice Event emitted when the global burn limit is set by the Owner.
    /// @param globalBurnLimit the new global burn limit.
    event GlobalBurnLimitSet(uint256 globalBurnLimit);

    /// @notice Event emitted when the fees rate is set by the Owner.
    /// @param feesRate the new fees rate.
    event FeesRateSet(uint16 feesRate);

    /// @notice Event emitted when the fees recipient is set by the Owner.
    /// @param feesRecipient the new fees recipient address.
    event FeesRecipientSet(address feesRecipient);

    /// @notice Event emitted when tokens are sent from the src chain to the dst chain.
    /// @param guid the GUID of the OFT message.
    /// @param dstEid the Eid code of the destination chain.
    /// @param fromAddress the Address of the token sender.
    /// @param isPrincipalTokenBurned the flag to indicate if the principal tokens are burned or OFTs.
    /// @param amountSentLD the amount sent in local decimals.
    /// @param amountReceive the amount expected to receive on the destination chain.
    event BridgeableTokenSent(
        bytes32 indexed guid,
        uint32 dstEid,
        address indexed fromAddress,
        bool isPrincipalTokenBurned,
        uint256 amountSentLD,
        uint256 amountReceive
    );

    /// @notice Event emitted when tokens are received from the src chain to the dst chain.
    /// @param guid the GUID of the OFT message.
    /// @param srcEid the Eid code of the source chain.
    /// @param toAddress the Address of the token receiver.
    /// @param amountReceivedLD the amount of tokens received in local decimals.
    /// @param oftReceived the amount of OFT received.
    /// @param feeAmountLD the amount of the fees in local decimals.
    event BridgeableTokenReceived(
        bytes32 indexed guid,
        uint32 srcEid,
        address indexed toAddress,
        uint256 amountReceivedLD,
        uint256 oftReceived,
        uint256 feeAmountLD
    );

    /// @notice Event emitted when the caller swap OFT for principal tokens.
    /// @param caller Address of the caller.
    /// @param amountToSwap Amount of OFT to swap.
    /// @param principalTokenAmountReceived Amount of principal tokens received.
    /// @param feeAmount Amount of fees in principal token.
    event OFTSwapped(address caller, uint256 amountToSwap, uint256 principalTokenAmountReceived, uint256 feeAmount);
}
