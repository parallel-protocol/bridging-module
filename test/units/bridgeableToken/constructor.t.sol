// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import "test/Units.t.sol";

contract BridgeableToken_Constructor_Units_Test is Units_Test {
    function test_Constructor() external {
        assertEq(aBridgeableToken.owner(), users.owner);
        assertEq(aBridgeableToken.getFeesRecipient(), users.feesRecipient);
        assertEq(aBridgeableToken.getPrincipalToken(), address(aPar));
        assertFalse(aBridgeableToken.getIsIsolateMode());
        assertEq(aBridgeableToken.getFeesRate(), DEFAULT_FEE_RATE);
        assertEq(aBridgeableToken.getMintDailyLimit(), DEFAULT_MINT_DAILY_LIMIT);
        assertEq(aBridgeableToken.getGlobalMintLimit(), DEFAULT_GLOBAL_MINT_LIMIT);
        assertEq(aBridgeableToken.getMaxMintableAmount(), DEFAULT_MINT_DAILY_LIMIT);
        assertEq(aBridgeableToken.getBurnDailyLimit(), DEFAULT_BURN_DAILY_LIMIT);
        assertEq(aBridgeableToken.getGlobalBurnLimit(), DEFAULT_GLOBAL_BURN_LIMIT);
        assertEq(aBridgeableToken.getMaxBurnableAmount(), DEFAULT_BURN_DAILY_LIMIT);
    }

    function test_revertWhen_PrincipalTokenIsAddressZero() external {
        vm.expectRevert(abi.encodeWithSelector(ErrorsLib.AddressZero.selector));
        new BridgeableToken(
            "aLz-Par",
            "aLzPAR",
            address(0),
            address(endpoints[aEid]),
            address(users.owner),
            configParams
        );
    }

    function test_revertWhen_FeesRecipientIsAddressZero() external {
        BridgeableToken.ConfigParams memory wrongConfigParams = BridgeableToken.ConfigParams({
            mintDailyLimit: DEFAULT_MINT_DAILY_LIMIT,
            globalMintLimit: DEFAULT_GLOBAL_MINT_LIMIT,
            burnDailyLimit: DEFAULT_BURN_DAILY_LIMIT,
            globalBurnLimit: DEFAULT_GLOBAL_BURN_LIMIT,
            feesRecipient: address(0),
            feesRate: DEFAULT_FEE_RATE,
            isIsolateMode: false
        });
        vm.expectRevert(abi.encodeWithSelector(ErrorsLib.AddressZero.selector));
        new BridgeableToken(
            "aLz-Par",
            "aLzPAR",
            address(aPar),
            address(endpoints[aEid]),
            address(users.owner),
            wrongConfigParams
        );
    }

    function test_revertWhen_FeesRateExceedMaxAllowed() external {
        BridgeableToken.ConfigParams memory wrongConfigParams = BridgeableToken.ConfigParams({
            mintDailyLimit: DEFAULT_MINT_DAILY_LIMIT,
            globalMintLimit: DEFAULT_GLOBAL_MINT_LIMIT,
            burnDailyLimit: DEFAULT_BURN_DAILY_LIMIT,
            globalBurnLimit: DEFAULT_GLOBAL_BURN_LIMIT,
            feesRecipient: users.feesRecipient,
            feesRate: ContractConstantsLib.MAX_FEE + 1,
            isIsolateMode: false
        });
        vm.expectRevert(abi.encodeWithSelector(ErrorsLib.MaxFeesRateExceeded.selector));
        new BridgeableToken(
            "aLz-Par",
            "aLzPAR",
            address(aPar),
            address(endpoints[aEid]),
            address(users.owner),
            wrongConfigParams
        );
    }
}
