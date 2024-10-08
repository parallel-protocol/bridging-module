// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import "../Integrations.t.sol";

contract BridgeableToken_SwapLzTokenToPrincipalToken_Integrations_Test is Integrations_Test {
    using OptionsBuilder for bytes;
    using PercentageMathLib for uint256;

    uint256 bLzParAmount;

    function setUp() public virtual override {
        super.setUp();
        vm.startPrank(users.owner);
        /// @dev By setting the mint daily limit to 0, we can only mint blz-PAR
        bBridgeableToken.setMintDailyLimit(0);

        /// @dev recieve bLz-PAR
        vm.startPrank(users.alice);
        bLzParAmount = _serializeAmountForOFT(DEFAULT_BURN_DAILY_LIMIT);
        _sendToken(aBridgeableToken, address(bBridgeableToken), bEid, true, bLzParAmount, users.alice);

        vm.startPrank(users.owner);
        bBridgeableToken.setMintDailyLimit(DEFAULT_MINT_DAILY_LIMIT);
    }

    function test_SwapLzTokenToPrincipalToken(uint256 swapAmount) external {
        vm.startPrank(users.alice);
        swapAmount = _boundBridgeAmount(swapAmount, 1e18, bLzParAmount);

        uint256 expectedFeesAmount = swapAmount.percentMul(DEFAULT_FEE_RATE);
        uint256 expectedReceivedAmount = swapAmount - expectedFeesAmount;

        bBridgeableToken.swapLzTokenToPrincipalToken(swapAmount);

        assertEq(bPar.balanceOf(users.alice), INITIAL_BALANCE + expectedReceivedAmount);
        assertEq(bPar.balanceOf(users.feesRecipient), expectedFeesAmount);
    }

    function test_SwapLzTokenToPrincipalToken_WithoutFees(uint256 swapAmount) external {
        vm.startPrank(users.owner);
        bBridgeableToken.setFeesRate(0);

        vm.startPrank(users.alice);
        swapAmount = _boundBridgeAmount(swapAmount, 1e18, bLzParAmount);

        bBridgeableToken.swapLzTokenToPrincipalToken(swapAmount);

        assertEq(bPar.balanceOf(users.alice), INITIAL_BALANCE + swapAmount);
        assertEq(bPar.balanceOf(users.feesRecipient), 0);
    }

    function test_RevertWhen_SwapAmountExceedsMintLimit(uint256 swapAmount) external {
        vm.startPrank(users.owner);
        bBridgeableToken.setMintDailyLimit(0);

        swapAmount = _boundBridgeAmount(swapAmount, 1e18, bLzParAmount);
        vm.startPrank(users.alice);
        vm.expectRevert(ErrorsLib.MintLimitExceeded.selector);
        bBridgeableToken.swapLzTokenToPrincipalToken(swapAmount);
    }
}
