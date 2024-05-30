// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import { PercentageMathLib } from "contracts/libraries/PercentageMathLib.sol";

import { Users } from "./Types.sol";

/// @notice Contract with default values used throughout the tests.
contract Defaults {
    using PercentageMathLib for uint256;


    //----------------------------------------
    // Constants
    //----------------------------------------

    uint256 public constant INITIAL_BALANCE = 100_000e18;
    uint16 public constant FEE_RATE = 250; // 2.5%
    uint32 public constant aEid = 1;
    uint32 public constant bEid = 2;
    uint32 public constant cEid = 3;

    //----------------------------------------
    // State variables
    //----------------------------------------
    
    Users internal users;

}
