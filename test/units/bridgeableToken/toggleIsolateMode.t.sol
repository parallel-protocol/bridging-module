// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import "test/Units.t.sol";

contract BridgeableToken_ToggleIsolateMode_Units_Test is Units_Test {
    modifier prankOwner() {
        vm.startPrank(users.owner);
        _;
    }

    function test_ToggleIsolateMode_FromFalseToTrue() external prankOwner {
        vm.expectEmit(address(aBridgeableToken));
        emit EventsLib.IsolateModeToggled(true);
        aBridgeableToken.toggleIsolateMode();
        assertTrue(aBridgeableToken.getIsIsolateMode());
    }

    modifier initIsIsolateModeToFalse() {
        aBridgeableToken.toggleIsolateMode();
        _;
    }

    function test_ToggleIsolateMode_FromTrueToFalse() external prankOwner initIsIsolateModeToFalse {
        vm.expectEmit(address(aBridgeableToken));
        emit EventsLib.IsolateModeToggled(false);
        aBridgeableToken.toggleIsolateMode();
        assertFalse(aBridgeableToken.getIsIsolateMode());
    }

    function test_RevertWhen_CallerNotOwner() external {
        vm.startPrank(users.hacker);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, users.hacker));
        aBridgeableToken.toggleIsolateMode();
    }
}
