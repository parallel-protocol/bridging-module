// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import {IERC20, SafeTransferLib} from "contracts/libraries/SafeTransferLib.sol";
import {ErrorsLib} from "contracts/libraries/ErrorsLib.sol";

import "./SafeTransferLibSetup.t.sol";

contract SafeTransferLib_SafeTransfer_Test is SafeTransferLibSetup {
    function test_SafeTransfer(address to, uint256 amount) public {
        tokenWithoutBoolean.setBalance(address(this), amount);

        this.safeTransfer(address(tokenWithoutBoolean), to, amount);
    }

    function test_RevertWhen_ReturnBoolFalse(address to, uint256 amount) public {
        tokenWithBooleanAlwaysFalse.setBalance(address(this), amount);

        vm.expectRevert(ErrorsLib.TransferReturnedFalse.selector);
        this.safeTransfer(address(tokenWithBooleanAlwaysFalse), to, amount);
    }

    function test_RevertWhen_TokenNotCreated(address token, address to, uint256 amount) public {
        vm.assume(token.code.length == 0);

        vm.expectRevert(ErrorsLib.NoCode.selector);
        this.safeTransfer(token, to, amount);
    }
}