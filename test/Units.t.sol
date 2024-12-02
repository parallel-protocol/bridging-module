// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import "test/Base.t.sol";

/// @notice Common logic for units tests.
abstract contract Units_Test is Base_Test {
    BridgeableToken.ConfigParams configParams;

    function setUp() public virtual override {
        Base_Test.setUp();

        configParams = BridgeableToken.ConfigParams({
            dailyCreditLimit: DEFAULT_DAILY_CREDIT_LIMIT,
            globalCreditLimit: DEFAULT_GLOBAL_CREDIT_LIMIT,
            dailyDebitLimit: DEFAULT_DAILY_DEBIT_LIMIT,
            globalDebitLimit: DEFAULT_GLOBAL_DEBIT_LIMIT,
            initialPrincipalTokenAmountMinted: DEFAULT_PRINCIPAL_TOKEN_AMOUNT_MINTED,
            initialCreditDebitBalance: DEFAULT_NET_BRIDGED_AMOUNT,
            feesRecipient: users.feesRecipient,
            feesRate: DEFAULT_FEE_RATE,
            isIsolateMode: false
        });

        setUpEndpoints(1, LibraryType.UltraLightNode);
        aBridgeableToken = new BridgeableToken(
            "aLz-Par",
            "aLzPAR",
            address(aPar),
            address(endpoints[aEid]),
            address(users.owner),
            configParams
        );
    }
}
