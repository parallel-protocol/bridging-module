// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import "test/Integrations.t.sol";

/// @notice Common logic needed by all invariants tests, both concrete and fuzz tests.
abstract contract Invariants_Test is Integrations_Test {
    bytes4[] internal selectors;

    function setUp() public virtual override {
        super.setUp();

        _targetSenders();

        _weightSelector(this.mine.selector, 100);

        targetContract(address(this));
        targetSelector(FuzzSelector({ addr: address(this), selectors: selectors }));
    }

    modifier logCall(string memory name) {
        console2.log(msg.sender, "->", name);
        _;
    }

    function _targetSenders() internal virtual {
        _targetSender(users.alice);
        _targetSender(users.bob);
    }

    function _targetSender(address sender) internal {
        targetSender(sender);

        vm.startPrank(sender);
        aPar.approve(address(aBridgeableToken), type(uint256).max);
        bPar.approve(address(bBridgeableToken), type(uint256).max);
        vm.stopPrank();
    }

    function _weightSelector(bytes4 selector, uint256 weight) internal {
        for (uint256 i; i < weight; ++i) {
            selectors.push(selector);
        }
    }

    function mine(uint256 blocks) external {
        blocks = bound(blocks, 1, 50_400);
        _forward(blocks);
    }
}
