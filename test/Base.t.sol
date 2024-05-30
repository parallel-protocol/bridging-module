// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import { StdCheats } from "@forge-std/StdCheats.sol";

import * as ContractConstantsLib from  "contracts/libraries/ConstantsLib.sol";
import { ErrorsLib } from "contracts/libraries/ErrorsLib.sol";
import { EventsLib } from "contracts/libraries/EventsLib.sol";

import "./utils/Types.sol";
import "./utils/Deploys.sol";
import "./utils/Defaults.sol";
import "./utils/Assertions.sol";


/// @notice Base test contract with common logic needed by all tests.
abstract contract Base_Test is Deploys, Assertions, Defaults, StdCheats {
    //----------------------------------------
    // Set-up
    //----------------------------------------

    function setUp() public virtual override {
        // Deploy aPar token contract.
        aPar = _deployERC20Mock("aPar", "aPar", 18);
        vm.label({ account: address(aPar), newLabel: "aPar" });
        // Deploy bPar token contract.
        bPar = _deployERC20Mock("bPar", "bPar", 18);
        vm.label({ account: address(bPar), newLabel: "bPar" });
        // Deploy cPar token contract.
        cPar = _deployERC20Mock("cPar", "cPar", 18);
        vm.label({ account: address(cPar), newLabel: "cPar" });

        // Create users for testing.
        users = Users({
            owner: _createUser("Owner", false),
            feeRecipient : _createUser("Fee Recipient", false),
            alice: _createUser("Alice", true),
            bob: _createUser("Bob", true),
            carole: _createUser("Carole", true),
            hacker: _createUser("Hacker", true)
        });

    }

    /// @dev Generates a user, labels its address, and funds it with test assets.
    function _createUser(string memory name, bool setTokenBalance) internal returns (address payable user) {
        user = payable(makeAddr(name));
        vm.deal({ account: user, newBalance: INITIAL_BALANCE });
        if (setTokenBalance) {
            deal({ token: address(aPar), to: user, give: INITIAL_BALANCE });
            deal({ token: address(bPar), to: user, give: INITIAL_BALANCE });
            deal({ token: address(cPar), to: user, give: INITIAL_BALANCE });
        }
    }

    
}
