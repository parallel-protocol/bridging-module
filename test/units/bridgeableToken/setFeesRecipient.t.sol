// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import "test/Units.t.sol";

contract BridgeableToken_SetFeesRecipient_Units_Test is Units_Test {
    address newFeesRecipient = vm.addr(100);

    function test_SetFeesRecipient() external {
        vm.startPrank(users.owner);
        vm.expectEmit(address(aBridgeableToken));
        emit EventsLib.FeesRecipientSet(newFeesRecipient);
        aBridgeableToken.setFeesRecipient(newFeesRecipient);
        assertEq(aBridgeableToken.getFeesRecipient(), newFeesRecipient);
    }

    function test_RevertWhen_CallerNotOwner() external {
        vm.startPrank(users.hacker);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, users.hacker));
        aBridgeableToken.setFeesRecipient(newFeesRecipient);
    }

    function test_RevertWhen_ValueIsAddressZero() external {
        vm.startPrank(users.owner);
        vm.expectRevert(abi.encodeWithSelector(ErrorsLib.AddressZero.selector));
        aBridgeableToken.setFeesRecipient(address(0));
    }
}
