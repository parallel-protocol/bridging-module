// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import "test/Units.t.sol";

contract BridgeableToken_SetDailyCreditLimit_Units_Test is Units_Test {
    uint256 newDailyCreditLimit = 100_000e18;

    function test_SetDailyCreditLimit() external {
        vm.startPrank(users.owner);
        vm.expectEmit(address(aBridgeableToken));
        emit EventsLib.DailyCreditLimitSet(newDailyCreditLimit);
        aBridgeableToken.setDailyCreditLimit(newDailyCreditLimit);
        assertEq(aBridgeableToken.getDailyCreditLimit(), newDailyCreditLimit);
    }

    function test_RevertWhen_CallerNotOwner() external {
        vm.startPrank(users.hacker);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, users.hacker));
        aBridgeableToken.setDailyCreditLimit(newDailyCreditLimit);
    }
}
