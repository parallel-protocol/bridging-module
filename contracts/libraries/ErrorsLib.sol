// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

/// @title ErrorsLib
/// @author Cooper Labs
/// @custom:contact security@cooperlabs.xyz
/// @notice Library exposing all errors link to the bridging module.
library ErrorsLib {
    /// @notice Thrown when the address is zero.
    error AddressZero();

    /// @notice Thrown when the amount of token to bridge from the current chain exceed the daily limit.
    error DailyDebitLimitReached();

    /// @notice Thrown when the amount of token to bridge from the current chain exceed the global limit allowed.
    error GlobalDebitLimitReached();

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

    /// @notice Thrown when the amount of OFT token to swap in principalToken exceeds the limit.
    error CreditLimitExceeded();

    /// @notice Thrown when the new globalLimit value exceed `MAX_GLOBAL_LIMIT`.
    error GlobalLimitOverFlow();

    /// @notice Thrown when the msg length is invalid.
    error InvalidMsgLength();
}
