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
        /// @dev By setting the daily credit limit to 0, we can only mint blz-PAR
        bBridgeableToken.setDailyCreditLimit(0);

        bLzParAmount = _serializeAmountForOFT(DEFAULT_DAILY_DEBIT_LIMIT);

        /// @dev recieve bLz-PAR
        vm.startPrank(users.alice);
        _sendToken(aBridgeableToken, address(bBridgeableToken), bEid, true, bLzParAmount, users.alice);

        vm.startPrank(users.owner);
        bBridgeableToken.setDailyCreditLimit(DEFAULT_DAILY_DEBIT_LIMIT);
    }

    function test_SwapLzTokenToPrincipalToken_MintNewPrincipalToken(uint256 swapAmount) external {
        vm.startPrank(users.alice);
        swapAmount = _boundBridgeAmount(swapAmount, 1e18, bLzParAmount);

        uint256 expectedFeesAmount = swapAmount.percentMul(DEFAULT_FEE_RATE);
        uint256 expectedReceivedAmount = swapAmount - expectedFeesAmount;

        bBridgeableToken.swapLzTokenToPrincipalToken(users.alice, swapAmount);

        assertEq(bPar.balanceOf(users.alice), INITIAL_BALANCE + expectedReceivedAmount);
        assertEq(bPar.balanceOf(users.feesRecipient), expectedFeesAmount);
        assertEq(bBridgeableToken.getPrincipalTokenAmountMinted(), swapAmount);
    }

    function test_SwapLzTokenToPrincipalToken_TransferLockedPrincipalToken(uint256 swapAmount) external {
        vm.startPrank(users.alice);
        swapAmount = _boundBridgeAmount(swapAmount, 1e18, bLzParAmount);
        /// @dev Transfer principal token to the bridgeable token to be used.
        bPar.mint(address(bBridgeableToken), swapAmount);
        uint256 expectedFeesAmount = swapAmount.percentMul(DEFAULT_FEE_RATE);
        uint256 expectedReceivedAmount = swapAmount - expectedFeesAmount;
        uint256 bParTotalSupplyBefore = bPar.totalSupply();

        bBridgeableToken.swapLzTokenToPrincipalToken(users.alice, swapAmount);

        assertEq(bPar.balanceOf(users.alice), INITIAL_BALANCE + expectedReceivedAmount);
        assertEq(bPar.balanceOf(users.feesRecipient), expectedFeesAmount);
        assertEq(bPar.balanceOf(address(bBridgeableToken)), 0);
        assertEq(bBridgeableToken.getPrincipalTokenAmountMinted(), 0);
        assertEq(bPar.totalSupply(), bParTotalSupplyBefore);
    }

    function test_SwapLzTokenToPrincipalToken_TransferAllLockedPrincipalTokenThenMint(uint256 swapAmount) external {
        vm.startPrank(users.alice);
        swapAmount = _boundBridgeAmount(swapAmount, 1e18, bLzParAmount);
        uint256 lockedAmount = _bound(1e18, 1e18, swapAmount);

        /// @dev Transfer some principal token to the bridgeable token to be used before minting.
        bPar.mint(address(bBridgeableToken), lockedAmount);
        uint256 expectedFeesAmount = swapAmount.percentMul(DEFAULT_FEE_RATE);
        uint256 expectedReceivedAmount = swapAmount - expectedFeesAmount;
        uint256 expectedPrincipalTokenAmountMinted = swapAmount - lockedAmount;
        uint256 bParTotalSupplyBefore = bPar.totalSupply();

        bBridgeableToken.swapLzTokenToPrincipalToken(users.alice, swapAmount);

        assertEq(bPar.balanceOf(users.alice), INITIAL_BALANCE + expectedReceivedAmount);
        assertEq(bPar.balanceOf(users.feesRecipient), expectedFeesAmount);
        assertEq(bPar.balanceOf(address(bBridgeableToken)), 0);
        assertEq(bBridgeableToken.getPrincipalTokenAmountMinted(), expectedPrincipalTokenAmountMinted);
        assertEq(bParTotalSupplyBefore, bPar.totalSupply() - expectedPrincipalTokenAmountMinted);
    }

    function test_SwapLzTokenToPrincipalToken(uint256 swapAmount) external {
        vm.startPrank(users.alice);
        swapAmount = _boundBridgeAmount(swapAmount, 1e18, bLzParAmount);

        uint256 expectedFeesAmount = swapAmount.percentMul(DEFAULT_FEE_RATE);
        uint256 expectedReceivedAmount = swapAmount - expectedFeesAmount;

        bBridgeableToken.swapLzTokenToPrincipalToken(users.alice, swapAmount);

        assertEq(bPar.balanceOf(users.alice), INITIAL_BALANCE + expectedReceivedAmount);
        assertEq(bPar.balanceOf(users.feesRecipient), expectedFeesAmount);
    }

    function test_SwapLzTokenToPrincipalToken_WithoutFees(uint256 swapAmount) external {
        vm.startPrank(users.owner);
        bBridgeableToken.setFeesRate(0);

        vm.startPrank(users.alice);
        swapAmount = _boundBridgeAmount(swapAmount, 1e18, bLzParAmount);

        bBridgeableToken.swapLzTokenToPrincipalToken(users.alice, swapAmount);

        assertEq(bPar.balanceOf(users.alice), INITIAL_BALANCE + swapAmount);
        assertEq(bPar.balanceOf(users.feesRecipient), 0);
    }

    function test_SwapLzTokenToPrincipalToken_LimitReducedAmountToSwap(uint256 swapAmount) external {
        swapAmount = _boundBridgeAmount(swapAmount, 1e18, bLzParAmount);
        uint256 totalExpectedAmountCredited = swapAmount / 2;
        uint256 expectedFeesAmount = totalExpectedAmountCredited.percentMul(DEFAULT_FEE_RATE);
        uint256 expectedAmountCredited = totalExpectedAmountCredited - expectedFeesAmount;
        uint256 dailyCreditLimit = totalExpectedAmountCredited;

        bBridgeableToken.setDailyCreditLimit(dailyCreditLimit);

        vm.startPrank(users.alice);
        bBridgeableToken.swapLzTokenToPrincipalToken(users.alice, swapAmount);

        assertEq(bPar.balanceOf(users.alice), INITIAL_BALANCE + expectedAmountCredited);
        assertEq(bPar.balanceOf(users.feesRecipient), expectedFeesAmount);
        assertEq(bBridgeableToken.balanceOf(users.alice), bLzParAmount - totalExpectedAmountCredited);
    }

    function test_RevertWhen_SwapAmountCalculatedIsZero(uint256 swapAmount) external {
        vm.startPrank(users.owner);
        bBridgeableToken.setDailyCreditLimit(0);

        swapAmount = _boundBridgeAmount(swapAmount, 1e18, bLzParAmount);
        vm.startPrank(users.alice);
        vm.expectRevert(ErrorsLib.NothingToSwap.selector);
        bBridgeableToken.swapLzTokenToPrincipalToken(users.alice, swapAmount);
    }

    function test_RevertWhen_ToIsAddressZero() external {
        vm.startPrank(users.alice);
        vm.expectRevert(ErrorsLib.AddressZero.selector);
        bBridgeableToken.swapLzTokenToPrincipalToken(address(0), 1e18);
    }
}
