// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import "test/Units.t.sol";

contract BridgeableToken_SetDailyDebitLimit_Units_Test is Units_Test {
    uint256 newDailyDebitLimit = 100_000e18;

    function test_SetDailyDebitLimit() external {
        vm.startPrank(users.owner);
        vm.expectEmit(address(aBridgeableToken));
        emit EventsLib.DailyDebitLimitSet(newDailyDebitLimit);
        aBridgeableToken.setDailyDebitLimit(newDailyDebitLimit);
        assertEq(aBridgeableToken.getDailyDebitLimit(), newDailyDebitLimit);
    }

    function test_RevertWhen_CallerNotOwner() external {
        vm.startPrank(users.hacker);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, users.hacker));
        aBridgeableToken.setDailyDebitLimit(newDailyDebitLimit);
    }
}
