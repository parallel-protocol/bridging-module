// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import { IERC20, SafeTransferLib } from "contracts/libraries/SafeTransferLib.sol";
import { ErrorsLib } from "contracts/libraries/ErrorsLib.sol";

import "./SafeTransferLibSetup.t.sol";

contract SafeTransferLib_SafeTransferFrom_Test is SafeTransferLibSetup {
    function test_SafeTransferFrom(address from, address to, uint256 amount) public {
        tokenWithoutBoolean.setBalance(from, amount);

        this.safeTransferFrom(address(tokenWithoutBoolean), from, to, amount);
    }

    function test_RevertWhen_ReturnBoolFalse(address from, address to, uint256 amount) public {
        tokenWithBooleanAlwaysFalse.setBalance(from, amount);

        vm.expectRevert(ErrorsLib.TransferFromReturnedFalse.selector);
        this.safeTransferFrom(address(tokenWithBooleanAlwaysFalse), from, to, amount);
    }

    function test_RevertWhen_TokenNotCreated(address from, address token, address to, uint256 amount) public {
        vm.assume(token.code.length == 0);

        vm.expectRevert(ErrorsLib.NoCode.selector);
        this.safeTransferFrom(token, from, to, amount);
    }
}
