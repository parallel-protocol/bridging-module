// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import { console2 } from "@forge-std/console2.sol";

import "contracts/libraries/ConstantsLib.sol" as ContractConstantsLib;
import { ErrorsLib } from "contracts/libraries/ErrorsLib.sol";
import { EventsLib } from "contracts/libraries/EventsLib.sol";

import "./helpers/Deploys.sol";
import "./helpers/Defaults.sol";
import "./helpers/Assertions.sol";
import "./helpers/utils.sol";

/// @notice Base test contract with common logic needed by all tests.
abstract contract Base_Test is Deploys, Assertions, Defaults, Utils {
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

        // Create users for testing.
        users = Users({
            owner: _createUser("Owner", false),
            feesRecipient: _createUser("Fee Recipient", false),
            alice: _createUser("Alice", true),
            bob: _createUser("Bob", true),
            hacker: _createUser("Hacker", true)
        });
    }

    /// @dev Generates a user, labels its address, and funds it with test assets.
    function _createUser(string memory name, bool setTokenBalance) internal returns (address payable user) {
        user = payable(makeAddr(name));
        vm.deal({ account: user, newBalance: INITIAL_BALANCE });
        if (setTokenBalance) {
            aPar.mint(user, INITIAL_BALANCE);
            bPar.mint(user, INITIAL_BALANCE);
        }
    }
}
