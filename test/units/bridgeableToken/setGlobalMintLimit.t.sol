// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import "test/Units.t.sol";

contract BridgeableToken_SetGlobalMintLimit_Units_Test is Units_Test {
    uint256 newGlobalMintLimit = 100_000_000e18;

    function test_SetGlobalMintLimit() external {
        vm.startPrank(users.owner);
        vm.expectEmit(address(aBridgeableToken));
        emit EventsLib.GlobalMintLimitSet(newGlobalMintLimit);
        aBridgeableToken.setGlobalMintLimit(newGlobalMintLimit);
        assertEq(aBridgeableToken.getGlobalMintLimit(), newGlobalMintLimit);
    }

    function test_RevertWhen_CallerNotOwner() external {
        vm.startPrank(users.hacker);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, users.hacker));
        aBridgeableToken.setGlobalMintLimit(newGlobalMintLimit);
    }

    function test_RevertWhen_ValueOverflowMaxGlobalLimit() external {
        vm.startPrank(users.owner);
        vm.expectRevert(abi.encodeWithSelector(ErrorsLib.GlobalLimitOverFlow.selector));
        aBridgeableToken.setGlobalMintLimit(uint256(type(int256).max) + 1);
    }
}
