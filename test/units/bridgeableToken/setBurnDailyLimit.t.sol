// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import "test/Units.t.sol";

contract BridgeableToken_SetBurnDailyLimit_Units_Test is Units_Test {
    uint256 newBurnDailyLimit = 100_000e18;

    function test_SetBurnDailyLimit() external {
        vm.startPrank(users.owner);
        vm.expectEmit(address(aBridgeableToken));
        emit EventsLib.BurnableDailyLimitSet(newBurnDailyLimit);
        aBridgeableToken.setBurnDailyLimit(newBurnDailyLimit);
        assertEq(aBridgeableToken.getBurnDailyLimit(), newBurnDailyLimit);
    }

    function test_RevertWhen_CallerNotOwner() external {
        vm.startPrank(users.hacker);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, users.hacker));
        aBridgeableToken.setBurnDailyLimit(newBurnDailyLimit);
    }
}
