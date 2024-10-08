// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import "../Integrations.t.sol";

contract BridgeableToken_Send_Integrations_Test is Integrations_Test {
    using OptionsBuilder for bytes;
    using PercentageMathLib for uint256;

    bool sendPrincipalToken = true;
    bool sendLzToken = false;

    function test_Send_PAR_Receive_PAR(uint256 amountToSend) external {
        amountToSend = _boundBridgeAmount(amountToSend, 1e18, DEFAULT_BURN_DAILY_LIMIT);
        uint256 expectedFeesAmount = amountToSend.percentMul(DEFAULT_FEE_RATE);
        uint256 expectedReceivedAmount = amountToSend - expectedFeesAmount;
        vm.startPrank(users.alice);

        _sendToken(aBridgeableToken, address(bBridgeableToken), bEid, sendPrincipalToken, amountToSend, users.alice);

        assertEq(aPar.balanceOf(users.alice), INITIAL_BALANCE - amountToSend);
        assertEq(aBridgeableToken.balanceOf(users.alice), 0);
        assertEq(aBridgeableToken.getCurrentMintDailyUsage(), 0);
        assertEq(aBridgeableToken.getCurrentBurnDailyUsage(), amountToSend);
        assertEq(aBridgeableToken.getNetMintedAmount(), -int256(amountToSend));
        assertEq(aBridgeableToken.getMaxBurnableAmount(), DEFAULT_BURN_DAILY_LIMIT - amountToSend);

        assertEq(bPar.balanceOf(users.alice), INITIAL_BALANCE + expectedReceivedAmount);
        assertEq(bPar.balanceOf(users.feesRecipient), expectedFeesAmount);
        assertEq(bBridgeableToken.balanceOf(users.alice), 0);
        assertEq(bBridgeableToken.getCurrentMintDailyUsage(), amountToSend);
        assertEq(bBridgeableToken.getCurrentBurnDailyUsage(), 0);
        assertEq(bBridgeableToken.getNetMintedAmount(), int256(amountToSend));
        assertEq(bBridgeableToken.getMaxMintableAmount(), DEFAULT_MINT_DAILY_LIMIT - amountToSend);
    }

    modifier getLzPar() {
        vm.startPrank(users.owner);
        /// @dev By setting the mint daily limit to 0, we can only mint blz-PAR
        bBridgeableToken.setMintDailyLimit(0);

        /// @dev recieve bLz-PAR
        vm.startPrank(users.alice);
        _sendToken(
            aBridgeableToken,
            address(bBridgeableToken),
            bEid,
            sendPrincipalToken,
            _serializeAmountForOFT(DEFAULT_BURN_DAILY_LIMIT),
            users.alice
        );
        _;
    }

    function test_Send_LzPAR_Receive_PAR(uint256 amountToSend) external getLzPar {
        vm.startPrank(users.alice);
        uint256 bLzParAmount = _serializeAmountForOFT(DEFAULT_BURN_DAILY_LIMIT);
        uint256 aParAliceBalance = INITIAL_BALANCE - bLzParAmount;
        amountToSend = _boundBridgeAmount(amountToSend, 1e18, bLzParAmount);

        assertEq(aPar.balanceOf(users.alice), aParAliceBalance);
        assertEq(bPar.balanceOf(users.alice), INITIAL_BALANCE);
        assertEq(bBridgeableToken.balanceOf(users.alice), bLzParAmount);

        _sendToken(bBridgeableToken, address(aBridgeableToken), aEid, sendLzToken, amountToSend, users.alice);

        assertEq(aPar.balanceOf(users.alice), aParAliceBalance + amountToSend);
        assertEq(aPar.balanceOf(users.feesRecipient), 0);

        assertEq(aBridgeableToken.balanceOf(users.alice), 0);
        assertEq(aBridgeableToken.getCurrentBurnDailyUsage(), bLzParAmount);
        assertEq(aBridgeableToken.getCurrentMintDailyUsage(), amountToSend);
        assertEq(aBridgeableToken.getNetMintedAmount(), int256(amountToSend) - int256(bLzParAmount));

        assertEq(bPar.balanceOf(users.alice), INITIAL_BALANCE);
        assertEq(bPar.balanceOf(users.feesRecipient), 0);
        assertEq(bBridgeableToken.balanceOf(users.alice), bLzParAmount - amountToSend);
        assertEq(bBridgeableToken.getCurrentMintDailyUsage(), 0);
        assertEq(bBridgeableToken.getCurrentBurnDailyUsage(), 0);
        assertEq(bBridgeableToken.getNetMintedAmount(), 0);
    }

    modifier reachGlobalMintLimit() {
        vm.startPrank(users.owner);
        /// @dev By setting the mint daily limit to 0, we direclty reach the global mint limit
        bBridgeableToken.setGlobalMintLimit(0);
        _;
    }

    function test_ReachGlobalMintLimitShouldReceiveLzPAR(uint256 amountToSend) external reachGlobalMintLimit {
        amountToSend = _boundBridgeAmount(amountToSend, 1e18, DEFAULT_BURN_DAILY_LIMIT);
        vm.startPrank(users.alice);
        _sendToken(aBridgeableToken, address(bBridgeableToken), bEid, sendPrincipalToken, amountToSend, users.alice);

        assertEq(aPar.balanceOf(users.alice), INITIAL_BALANCE - amountToSend);
        assertEq(aBridgeableToken.balanceOf(users.alice), 0);
        assertEq(aBridgeableToken.getCurrentBurnDailyUsage(), amountToSend);
        assertEq(aBridgeableToken.getCurrentMintDailyUsage(), 0);
        assertEq(aBridgeableToken.getNetMintedAmount(), -int256(amountToSend));

        assertEq(bPar.balanceOf(users.alice), INITIAL_BALANCE);
        assertEq(bPar.balanceOf(users.feesRecipient), 0);
        assertEq(bBridgeableToken.balanceOf(users.alice), amountToSend);
        assertEq(bBridgeableToken.getCurrentMintDailyUsage(), 0);
        assertEq(bBridgeableToken.getCurrentBurnDailyUsage(), 0);
        assertEq(bBridgeableToken.getNetMintedAmount(), 0);
    }

    modifier reachMintDailyLimit() {
        vm.startPrank(users.owner);
        /// @dev By setting the mint daily limit to 0, we direclty reach the global mint limit
        bBridgeableToken.setMintDailyLimit(0);
        _;
    }

    function test_ReachMintDailyLimitShouldReceiveLzPAR(uint256 amountToSend) external reachMintDailyLimit {
        amountToSend = _boundBridgeAmount(amountToSend, 1e18, DEFAULT_BURN_DAILY_LIMIT);
        vm.startPrank(users.alice);
        _sendToken(aBridgeableToken, address(bBridgeableToken), bEid, sendPrincipalToken, amountToSend, users.alice);

        assertEq(aPar.balanceOf(users.alice), INITIAL_BALANCE - amountToSend);
        assertEq(aBridgeableToken.balanceOf(users.alice), 0);
        assertEq(aBridgeableToken.getCurrentBurnDailyUsage(), amountToSend);
        assertEq(aBridgeableToken.getCurrentMintDailyUsage(), 0);
        assertEq(aBridgeableToken.getNetMintedAmount(), -int256(amountToSend));

        assertEq(bPar.balanceOf(users.alice), INITIAL_BALANCE);
        assertEq(bPar.balanceOf(users.feesRecipient), 0);
        assertEq(bBridgeableToken.balanceOf(users.alice), amountToSend);
        assertEq(bBridgeableToken.getCurrentMintDailyUsage(), 0);
        assertEq(bBridgeableToken.getCurrentBurnDailyUsage(), 0);
        assertEq(bBridgeableToken.getNetMintedAmount(), 0);
    }

    modifier reachBurnDailyLimit() {
        vm.startPrank(users.owner);
        aBridgeableToken.setBurnDailyLimit(0);
        _;
    }

    function test_RevertWhen_BurnDailyLimitReached(uint256 amountToSend) external reachBurnDailyLimit {
        amountToSend = _boundBridgeAmount(amountToSend, DEFAULT_BURN_DAILY_LIMIT, uint256(type(int256).max));

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        SendParam memory sendParam = SendParam(
            bEid,
            addressToBytes32(users.alice),
            amountToSend,
            amountToSend,
            options,
            abi.encode(sendPrincipalToken),
            ""
        );

        MessagingFee memory fees = aBridgeableToken.quoteSend(sendParam, false);
        vm.startPrank(users.alice);
        vm.expectRevert(ErrorsLib.BurnDailyLimitReached.selector);
        aBridgeableToken.send{ value: fees.nativeFee }(sendParam, fees, payable(users.alice));
    }

    modifier reachGlobalBurnLimit() {
        vm.startPrank(users.owner);
        aBridgeableToken.setGlobalBurnLimit(0);
        _;
    }

    function test_RevertWhen_GlobalBurnLimitReached(uint256 amountToSend) external reachGlobalBurnLimit {
        amountToSend = _boundBridgeAmount(amountToSend, 1e18, DEFAULT_BURN_DAILY_LIMIT);

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        SendParam memory sendParam = SendParam(
            bEid,
            addressToBytes32(users.alice),
            amountToSend,
            amountToSend,
            options,
            abi.encode(sendPrincipalToken),
            ""
        );

        MessagingFee memory fees = aBridgeableToken.quoteSend(sendParam, false);

        vm.startPrank(users.alice);
        vm.expectRevert(ErrorsLib.GlobalBurnLimitReached.selector);
        aBridgeableToken.send{ value: fees.nativeFee }(sendParam, fees, payable(users.alice));
    }

    modifier setIsolateMode() {
        vm.startPrank(users.owner);
        aBridgeableToken.toggleIsolateMode();
        _;
    }

    function test_RevertWhen_InIsolateModeNetMintedAmountBelowZero(uint256 amountToSend) external setIsolateMode {
        amountToSend = _boundBridgeAmount(amountToSend, 1e18, DEFAULT_BURN_DAILY_LIMIT);

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        SendParam memory sendParam = SendParam(
            bEid,
            addressToBytes32(users.alice),
            amountToSend,
            amountToSend,
            options,
            abi.encode(sendPrincipalToken),
            ""
        );

        MessagingFee memory fees = aBridgeableToken.quoteSend(sendParam, false);

        vm.startPrank(users.alice);
        vm.expectRevert(ErrorsLib.IsolateModeLimitReach.selector);
        aBridgeableToken.send{ value: fees.nativeFee }(sendParam, fees, payable(users.alice));
    }

    modifier mintAndUpdateGlobalMintAmount(uint256 amountToSend) {
        amountToSend = _boundBridgeAmount(amountToSend, 1e18, DEFAULT_BURN_DAILY_LIMIT / 10);
        uint256 expectedFeesAmount = amountToSend.percentMul(DEFAULT_FEE_RATE);
        uint256 expectedReceivedAmount = amountToSend - expectedFeesAmount;
        vm.startPrank(users.alice);
        _sendToken(aBridgeableToken, address(bBridgeableToken), bEid, sendPrincipalToken, amountToSend, users.alice);

        vm.startPrank(users.owner);
        bBridgeableToken.setGlobalMintLimit(expectedReceivedAmount / 10);
        _;
    }

    function test_ReceivedOFT_When_GlobalMintAmountUpdatedBelowNetMintedAmount(
        uint256 amountToSend
    ) external mintAndUpdateGlobalMintAmount(amountToSend) {
        amountToSend = _boundBridgeAmount(amountToSend, 1e18, DEFAULT_BURN_DAILY_LIMIT / 10);
        uint256 bLzParAmountAlice = bBridgeableToken.balanceOf(users.alice);
        uint256 aParAmountAlice = aPar.balanceOf(users.alice);
        uint256 bParAmountAlice = bPar.balanceOf(users.alice);
        vm.startPrank(users.alice);
        _sendToken(aBridgeableToken, address(bBridgeableToken), bEid, sendPrincipalToken, amountToSend, users.alice);

        assertEq(aPar.balanceOf(users.alice), aParAmountAlice - amountToSend);
        assertEq(bPar.balanceOf(users.alice), bParAmountAlice);
        assertEq(bBridgeableToken.balanceOf(users.alice), bLzParAmountAlice + amountToSend);
    }

    function test_RevertWhen_ComposeMsgLengthIsNot32Bytes() external {
        uint256 amountToSend = 1e18;
        vm.startPrank(users.alice);
        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);

        /// @dev ComposeMsg is empty
        SendParam memory sendParam = SendParam(
            bEid,
            addressToBytes32(users.alice),
            amountToSend,
            amountToSend,
            options,
            "",
            ""
        );
        MessagingFee memory fees = aBridgeableToken.quoteSend(sendParam, false);
        vm.expectRevert(ErrorsLib.InvalidMsgLength.selector);
        aBridgeableToken.send{ value: fees.nativeFee }(sendParam, fees, payable(users.alice));

        /// @dev ComposeMsg length is greater than 32 bytes
        sendParam = SendParam(
            bEid,
            addressToBytes32(users.alice),
            amountToSend,
            amountToSend,
            options,
            abi.encode(true, false),
            ""
        );
        fees = aBridgeableToken.quoteSend(sendParam, false);
        vm.expectRevert(ErrorsLib.InvalidMsgLength.selector);
        aBridgeableToken.send{ value: fees.nativeFee }(sendParam, fees, payable(users.alice));
    }
}
