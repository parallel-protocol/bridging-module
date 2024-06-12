// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import "test/Units.t.sol";

contract BridgeableToken_Unpause_Units_Test is Units_Test {
    function setUp() public virtual override {
        super.setUp();
        vm.startPrank(users.owner);
        aBridgeableToken.pause();
    }

    function test_Pause() external {
        vm.startPrank(users.owner);
        vm.expectEmit(address(aBridgeableToken));
        emit Pausable.Unpaused(users.owner);
        aBridgeableToken.unpause();
        assertFalse(aBridgeableToken.paused());
    }

    function test_RevertWhen_CallerNotOwner() external {
        vm.startPrank(users.hacker);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, users.hacker));
        aBridgeableToken.unpause();
    }
}
