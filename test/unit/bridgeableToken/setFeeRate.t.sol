// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";


import "../shared/BridgeableToken.t.sol";

contract BridgeableToken_SetFeeRate_Integrations_Test is BridgeableToken_Unit_Test {
    
    function test_SetFeeRate() external {
        vm.startPrank(users.owner);
        vm.expectEmit(address(aBridgeableToken));
        emit EventsLib.FeeRateSet(FEE_RATE);
        aBridgeableToken.setFeeRate(FEE_RATE);
        assertEq(aBridgeableToken.getFeeRate(),FEE_RATE);
    }

    function test_RevertWhen_CallerNotOwner() external {
        vm.startPrank(users.hacker);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, users.hacker));
        aBridgeableToken.setFeeRate(FEE_RATE);
    }

    function test_RevertWhen_ValueExceedMaxFeeAllowed() external{
        vm.startPrank(users.owner);
        vm.expectRevert(abi.encodeWithSelector(ErrorsLib.MaxFeeRateExceeded.selector));
        aBridgeableToken.setFeeRate(ContractConstantsLib.MAX_FEE + 1);
    }

}