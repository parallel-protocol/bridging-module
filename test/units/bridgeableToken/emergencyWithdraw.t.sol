// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import "test/Units.t.sol";

contract BridgeableToken_Unpause_Units_Test is Units_Test {
    function setUp() public virtual override {
        super.setUp();
        aPar.mint(address(aBridgeableToken), INITIAL_BALANCE);

        vm.startPrank(users.owner);
        aBridgeableToken.pause();
    }

    function test_EmergencyWithdraw() external {
        vm.startPrank(users.owner);
        aBridgeableToken.emergencyWithdraw(INITIAL_BALANCE);
        assertEq(aPar.balanceOf(address(aBridgeableToken)), 0);
        assertEq(aPar.balanceOf(users.owner), INITIAL_BALANCE);
    }

    function test_RevertWhen_CallerNotOwner() external {
        vm.startPrank(users.hacker);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, users.hacker));
        aBridgeableToken.emergencyWithdraw(INITIAL_BALANCE);
    }

    modifier unpauseContract() {
        vm.startPrank(users.owner);
        aBridgeableToken.unpause();
        _;
    }

    function test_RevertWhen_ContractPaused() external unpauseContract {
        vm.startPrank(users.owner);
        vm.expectRevert(abi.encodeWithSelector(Pausable.ExpectedPause.selector));
        aBridgeableToken.emergencyWithdraw(INITIAL_BALANCE);
    }
}
