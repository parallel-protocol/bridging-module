// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import "test/Base.t.sol";

/// @notice Common logic needed by all integration tests, both concrete and fuzz tests.
abstract contract BridgeableToken_Unit_Test is Base_Test {

    function setUp() public virtual override {
        Base_Test.setUp();

        setUpEndpoints(1, LibraryType.UltraLightNode);
        aBridgeableToken = new BridgeableToken ("aLz-Par", "aLzPAR", address(aPar), address(endpoints[aEid]), address(users.owner), address(users.feeRecipient));
    }
}