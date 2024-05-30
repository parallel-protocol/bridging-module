// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import "../shared/BridgeableToken.t.sol";

contract BridgeableToken_SetFeeRecipient_Integrations_Test is BridgeableToken_Unit_Test {
    address newFeeRecipient =  vm.addr(100);


    function test_SetFeeRecipient() external {
        vm.startPrank(users.owner);
        vm.expectEmit(address(aBridgeableToken));
        emit EventsLib.FeeRecipientSet(newFeeRecipient);
        aBridgeableToken.setFeeRecipient(newFeeRecipient);
        assertEq(aBridgeableToken.getFeeRecipient(), newFeeRecipient);
    }

    function test_RevertWhen_CallerNotOwner() external {
        vm.startPrank(users.hacker);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, users.hacker));
        aBridgeableToken.setFeeRecipient(newFeeRecipient);
    }

    function test_RevertWhen_ValueIsAddressZero() external {
        vm.startPrank(users.owner);
        vm.expectRevert(abi.encodeWithSelector(ErrorsLib.AddressZero.selector));
        aBridgeableToken.setFeeRecipient(address(0));
    }

}