// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

/// @title ErrorsLib
/// @author Murphyy Labs
/// @custom:contact security@murphylabs.io
/// @notice Library exposing all errors link to the bridging module.
library ErrorsLib {
    /// @notice Thrown when the address is zero.
    error AddressZero();

    /// @notice Thrown when the amount of token to bridge from the current chain exceed the daily limit.
    error BurnDailyLimitReached();

    /// @notice Thrown when the amount of token to bridge from the current chain exceed the global limit allowed.
    error GlobalBurnLimitReached();

    /// @notice Thrown when the amount to transfer exceed to limit.
    error MaxAmountTransferReached();

    /// @notice Thrown when a token to transfer doesn't have code.
    error NoCode();

    /// @notice Thrown when the new fees rate exceeds the maximum fees.
    error MaxFeesRateExceeded();

    /// @notice Thrown when in isolate mode the amount to bridge exceed the total amount minted on the current chain.
    error IsolateModeLimitReach();

    /// @notice Thrown when a token transfer reverted.
    error TransferReverted();

    /// @notice Thrown when a token transfer returned false.
    error TransferReturnedFalse();

    /// @notice Thrown when a token transferFrom reverted.
    error TransferFromReverted();

    /// @notice Thrown when a token transferFrom returned false
    error TransferFromReturnedFalse();

    /// @notice Thrown when the amount of OFT token to withdraw in innerToken exceeds the limit.
    error MintLimitExceeded();

    /// @notice Thrown when the new globalBurnLimit value exceed the min int256 value.
    error GlobalBurnLimitCantExceedMinInt256();

    /// @notice Thrown when the new globalMintLimit value exceed the max int256 value.
    error GlobalMintLimitCantExceedMaxInt256();
}
