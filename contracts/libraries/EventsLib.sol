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

    /// @notice Event emitted when the fee rate is set by the Owner.
    event FeeRateSet(uint16 feeRate);

    /// @notice Event emitted when the fee recipient is set by the Owner.
    event FeeRecipientSet(address feeRecipient);

    /// @notice Event emitted when the fee recipient is set by the Owner.
    event OFTSent(
        bytes32 indexed guid, // GUID of the OFT message.
        uint32 dstEid, // Destination Endpoint ID.
        address indexed fromAddress, // Address of the sender on the src chain.
        bool isInnerTokenToBurn, // True if the inner token is burn, False for the OFT.
        uint256 amountSentLD, // Amount of tokens sent in local decimals.
        uint256 amountReceive // Amount of innerTokens received.
    );

    event OFTReceived(
        bytes32 indexed guid, // GUID of the OFT message.
        uint32 srcEid, // Source Endpoint ID.
        address indexed toAddress, // Address of the recipient on the dst chain.
        uint256 amountReceivedLD, // Amount of tokens received in local decimals.
        uint256 oftReceived, // Amount of OFT received.
        uint256 feeAmountLD // Amount of the fee in local decimals.
    );
}