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
        assertEq(aBridgeableToken.getDailyCreditLimit(), DEFAULT_DAILY_CREDIT_LIMIT);
        assertEq(aBridgeableToken.getGlobalCreditLimit(), DEFAULT_GLOBAL_CREDIT_LIMIT);
        assertEq(aBridgeableToken.getDailyDebitLimit(), DEFAULT_DAILY_DEBIT_LIMIT);
        assertEq(aBridgeableToken.getGlobalDebitLimit(), DEFAULT_GLOBAL_DEBIT_LIMIT);
        assertEq(aBridgeableToken.getMaxDebitableAmount(), DEFAULT_DAILY_DEBIT_LIMIT);
        assertEq(aBridgeableToken.getPrincipalTokenAmountMinted(), DEFAULT_PRINCIPAL_TOKEN_AMOUNT_MINTED);
        assertEq(aBridgeableToken.getCreditDebitBalance(), DEFAULT_NET_BRIDGED_AMOUNT);
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
            dailyCreditLimit: DEFAULT_DAILY_CREDIT_LIMIT,
            globalCreditLimit: DEFAULT_GLOBAL_CREDIT_LIMIT,
            dailyDebitLimit: DEFAULT_DAILY_DEBIT_LIMIT,
            globalDebitLimit: DEFAULT_GLOBAL_DEBIT_LIMIT,
            initialPrincipalTokenAmountMinted: DEFAULT_PRINCIPAL_TOKEN_AMOUNT_MINTED,
            initialCreditDebitBalance: DEFAULT_NET_BRIDGED_AMOUNT,
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
            dailyCreditLimit: DEFAULT_DAILY_CREDIT_LIMIT,
            globalCreditLimit: DEFAULT_GLOBAL_CREDIT_LIMIT,
            dailyDebitLimit: DEFAULT_DAILY_DEBIT_LIMIT,
            globalDebitLimit: DEFAULT_GLOBAL_DEBIT_LIMIT,
            initialPrincipalTokenAmountMinted: DEFAULT_PRINCIPAL_TOKEN_AMOUNT_MINTED,
            initialCreditDebitBalance: DEFAULT_NET_BRIDGED_AMOUNT,
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
