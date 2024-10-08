// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import { PercentageMathLib } from "contracts/libraries/PercentageMathLib.sol";

import { Users } from "./Types.sol";

/// @notice Contract with default values used throughout the tests.
contract Defaults {
    using PercentageMathLib for uint256;

    //----------------------------------------
    // Constants
    //----------------------------------------

    uint256 public constant ONE_DAY_IN_SECONDS = 1 days;
    uint256 public constant INITIAL_BALANCE = 100_000_000e18;
    uint16 public constant DEFAULT_FEE_RATE = 250; // 2.5%
    uint256 public constant DEFAULT_MINT_DAILY_LIMIT = 1_000e18;
    uint256 public constant DEFAULT_BURN_DAILY_LIMIT = 1_000e18;
    uint256 public constant DEFAULT_GLOBAL_MINT_LIMIT = 10_000e18;
    uint256 public constant DEFAULT_GLOBAL_BURN_LIMIT = 10_000e18;
    uint32 public constant aEid = 1;
    uint32 public constant bEid = 2;

    //----------------------------------------
    // State variables
    //----------------------------------------

    Users internal users;
}
