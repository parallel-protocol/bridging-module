// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

/// @title EventsLib
/// @author Murphyy Labs
/// @custom:contact security@murphylabs.io
/// @notice Library exposing all errors link to the bridging module.
library EventsLib {
    /// @notice Event emitted when the isolate mode is toggled by the Owner.
    event IsolateModeToggled(bool isolateMode);

    /// @notice Event emitted when the mintable daily limit is set by the Owner.
    event MintableDailyLimitSet(uint256 mintableDailyLimit);

    /// @notice Event emitted when the burnable daily limit is set by the Owner.
    event BurnableDailyLimitSet(uint256 burnableDailyLimit);

    /// @notice Event emitted when the global mint limit is set by the Owner.
    event GlobalMintLimitSet(uint256 globalMintLimit);

    /// @notice Event emitted when the global burn limit is set by the Owner.
    event GlobalBurnLimitSet(uint256 globalBurnLimit);

    /// @notice Event emitted when the fees rate is set by the Owner.
    event FeesRateSet(uint16 feesRate);

    /// @notice Event emitted when the fees recipient is set by the Owner.
    event FeesRecipientSet(address feesRecipient);

    /// @notice Event emitted when the fees recipient is set by the Owner.
    // Destination Endpoint ID.
    // Address of the sender on the src chain.
    // True if the principal token is burn, False for the OFT.
    // Amount of tokens sent in local decimals.
    // Amount of principalTokens received.
    // GUID of the OFT message.
    event OFTSent(
        bytes32 indexed guid,
        uint32 dstEid,
        address indexed fromAddress,
        bool isPrincipalTokenBurned,
        uint256 amountSentLD,
        uint256 amountReceive
    );

    // Source Endpoint ID.
    // Address of the recipient on the dst chain.
    // Amount of tokens received in local decimals.
    // Amount of OFT received.
    // Amount of the fees in local decimals.
    // GUID of the OFT message.
    event OFTReceived(
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
    /// @param principalTokenAmountRecieved Amount of principal tokens received.
    /// @param feeAmount Amount of fees in principal token.
    event OFTSwapped(address caller, uint256 amountToSwap, uint256 principalTokenAmountRecieved, uint256 feeAmount);
}
