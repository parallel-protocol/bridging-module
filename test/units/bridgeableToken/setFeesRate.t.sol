// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import "test/Units.t.sol";

contract BridgeableToken_SetFeesRate_Units_Test is Units_Test {
    function test_SetFeesRate() external {
        vm.startPrank(users.owner);
        vm.expectEmit(address(aBridgeableToken));
        emit EventsLib.FeesRateSet(DEFAULT_FEE_RATE);
        aBridgeableToken.setFeesRate(DEFAULT_FEE_RATE);
        assertEq(aBridgeableToken.getFeesRate(), DEFAULT_FEE_RATE);
    }

    function test_RevertWhen_CallerNotOwner() external {
        vm.startPrank(users.hacker);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, users.hacker));
        aBridgeableToken.setFeesRate(DEFAULT_FEE_RATE);
    }

    function test_RevertWhen_ValueExceedMaxFeeAllowed() external {
        vm.startPrank(users.owner);
        vm.expectRevert(abi.encodeWithSelector(ErrorsLib.MaxFeesRateExceeded.selector));
        aBridgeableToken.setFeesRate(ContractConstantsLib.MAX_FEE + 1);
    }
}
