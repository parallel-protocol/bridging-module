// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import "test/Base.t.sol";

/// @notice Common logic for units tests.
abstract contract Units_Test is Base_Test {
    BridgeableToken.ConfigParams configParams;

    function setUp() public virtual override {
        Base_Test.setUp();

        configParams = BridgeableToken.ConfigParams({
            mintDailyLimit: DEFAULT_MINT_DAILY_LIMIT,
            globalMintLimit: DEFAULT_GLOBAL_MINT_LIMIT,
            burnDailyLimit: DEFAULT_BURN_DAILY_LIMIT,
            globalBurnLimit: DEFAULT_GLOBAL_BURN_LIMIT,
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
