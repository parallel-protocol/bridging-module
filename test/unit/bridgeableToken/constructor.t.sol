// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import "../shared/BridgeableToken.t.sol";

contract BridgeableToken_Constructor_Integrations_Test is BridgeableToken_Unit_Test {

    function test_constructor() external{
        assertEq(aBridgeableToken.owner(), users.owner);
        assertEq(aBridgeableToken.getFeeRecipient(), users.feeRecipient);
        assertEq(aBridgeableToken.getInnerToken(), address(aPar));
        assertFalse(aBridgeableToken.getIsIsolateMode());
    }

    function test_revertWhen_innerTokenIsAddressZero() external{
        vm.expectRevert(abi.encodeWithSelector(ErrorsLib.AddressZero.selector));
        new BridgeableToken("aLz-Par", "aLzPAR", address(0), address(endpoints[aEid]), address(users.owner),  address(users.feeRecipient));
    }

    function test_revertWhen_feeRecipientIsAddressZero() external{
        vm.expectRevert(abi.encodeWithSelector(ErrorsLib.AddressZero.selector));
        new BridgeableToken("aLz-Par", "aLzPAR", address(aPar), address(endpoints[aEid]), address(users.owner), address(0));
    }

}