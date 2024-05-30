// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import "../shared/BridgeableToken.t.sol";

contract BridgeableToken_SetGlobalBurnLimit_Integrations_Test is BridgeableToken_Unit_Test {
    uint256 newGlobalBurnLimit = 100_000_000e18;   
    function test_SetGlobalBurnLimit() external {
        vm.startPrank(users.owner);
        vm.expectEmit(address(aBridgeableToken));
        emit EventsLib.GlobalBurnLimitSet(newGlobalBurnLimit);
        aBridgeableToken.setGlobalBurnLimit(newGlobalBurnLimit);
        assertEq(aBridgeableToken.getGlobalBurnLimit(),newGlobalBurnLimit);
    }

    function test_RevertWhen_CallerNotOwner() external {
        vm.startPrank(users.hacker);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, users.hacker));
        aBridgeableToken.setGlobalBurnLimit(newGlobalBurnLimit);
    }
}