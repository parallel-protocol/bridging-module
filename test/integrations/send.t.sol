// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import "../Integrations.t.sol";

contract BridgeableToken_Send_Integrations_Test is Integrations_Test {
    using OptionsBuilder for bytes;
    using PercentageMathLib for uint256;

    uint256 PRINCIPAL_TOKEN_AMOUNT_MINTED = DEFAULT_DAILY_DEBIT_LIMIT / 2;
    bool sendPrincipalToken = true;
    bool sendLzToken = false;

    function test_Send_Lock_PAR_Receive_PAR(uint256 amountToSend) external {
        amountToSend = _boundBridgeAmount(amountToSend, 1e18, DEFAULT_DAILY_DEBIT_LIMIT);
        uint256 expectedFeesAmount = amountToSend.percentMul(DEFAULT_FEE_RATE);
        uint256 expectedReceivedAmount = amountToSend - expectedFeesAmount;
        vm.startPrank(users.alice);

        _sendToken(aBridgeableToken, address(bBridgeableToken), bEid, sendPrincipalToken, amountToSend, users.alice);

        assertEq(aPar.balanceOf(users.alice), INITIAL_BALANCE - amountToSend);
        assertEq(aPar.balanceOf(address(aBridgeableToken)), amountToSend);
        assertEq(aBridgeableToken.balanceOf(users.alice), 0);
        assertEq(aBridgeableToken.getCurrentDailyCreditAmount(), 0);
        assertEq(aBridgeableToken.getCurrentDailyDebitAmount(), amountToSend);
        assertEq(aBridgeableToken.getCreditDebitBalance(), -int256(amountToSend));
        assertEq(aBridgeableToken.getMaxDebitableAmount(), DEFAULT_DAILY_DEBIT_LIMIT - amountToSend);

        assertEq(bPar.balanceOf(users.alice), INITIAL_BALANCE + expectedReceivedAmount);
        assertEq(bPar.balanceOf(users.feesRecipient), expectedFeesAmount);
        assertEq(bBridgeableToken.balanceOf(users.alice), 0);
        assertEq(bBridgeableToken.getPrincipalTokenAmountMinted(), amountToSend);
        assertEq(bBridgeableToken.getCurrentDailyCreditAmount(), amountToSend);
        assertEq(bBridgeableToken.getCurrentDailyDebitAmount(), 0);
        assertEq(bBridgeableToken.getCreditDebitBalance(), int256(amountToSend));
        assertEq(bBridgeableToken.getMaxCreditableAmount(), DEFAULT_DAILY_CREDIT_LIMIT - amountToSend);
    }

    function test_Send_Burn_PAR_Receive_PAR(
        uint256 amountToSend
    ) external deployBridgeableTokenToBurnOnSend(INITIAL_BALANCE) {
        amountToSend = _boundBridgeAmount(amountToSend, 1e18, DEFAULT_DAILY_DEBIT_LIMIT);
        uint256 expectedFeesAmount = amountToSend.percentMul(DEFAULT_FEE_RATE);
        uint256 expectedReceivedAmount = amountToSend - expectedFeesAmount;
        uint256 prevTotalSupply = aPar.totalSupply();
        vm.startPrank(users.alice);

        _sendToken(aBridgeableToken, address(bBridgeableToken), bEid, sendPrincipalToken, amountToSend, users.alice);

        assertEq(aPar.balanceOf(users.alice), INITIAL_BALANCE - amountToSend);
        assertEq(aPar.balanceOf(address(aBridgeableToken)), 0);
        assertEq(aPar.totalSupply(), prevTotalSupply - amountToSend);
        assertEq(aBridgeableToken.balanceOf(users.alice), 0);
        assertEq(aBridgeableToken.getCurrentDailyCreditAmount(), 0);
        assertEq(aBridgeableToken.getCurrentDailyDebitAmount(), amountToSend);
        assertEq(aBridgeableToken.getCreditDebitBalance(), -int256(amountToSend));
        assertEq(aBridgeableToken.getMaxDebitableAmount(), DEFAULT_DAILY_DEBIT_LIMIT - amountToSend);

        assertEq(bPar.balanceOf(users.alice), INITIAL_BALANCE + expectedReceivedAmount);
        assertEq(bPar.balanceOf(users.feesRecipient), expectedFeesAmount);
        assertEq(bBridgeableToken.balanceOf(users.alice), 0);
        assertEq(bBridgeableToken.getPrincipalTokenAmountMinted(), amountToSend);
        assertEq(bBridgeableToken.getCurrentDailyCreditAmount(), amountToSend);
        assertEq(bBridgeableToken.getCurrentDailyDebitAmount(), 0);
        assertEq(bBridgeableToken.getCreditDebitBalance(), int256(amountToSend));
        assertEq(bBridgeableToken.getMaxCreditableAmount(), DEFAULT_DAILY_CREDIT_LIMIT - amountToSend);
    }

    function test_Send_BurnUntilPrincipalTokenAmountMintedIsZeroThanLockPAR_Receive_PAR(
        uint256 amountToSend
    ) external deployBridgeableTokenToBurnOnSend(PRINCIPAL_TOKEN_AMOUNT_MINTED) {
        amountToSend = _boundBridgeAmount(amountToSend, 1e18, DEFAULT_DAILY_DEBIT_LIMIT);
        uint256 expectedFeesAmount = amountToSend.percentMul(DEFAULT_FEE_RATE);
        uint256 expectedReceivedAmount = amountToSend - expectedFeesAmount;
        uint256 expectedPrincipalTokenAmountLocked = amountToSend > PRINCIPAL_TOKEN_AMOUNT_MINTED
            ? amountToSend - PRINCIPAL_TOKEN_AMOUNT_MINTED
            : 0;
        uint256 expectedPrincipalTokenAmountBurned = amountToSend > PRINCIPAL_TOKEN_AMOUNT_MINTED
            ? PRINCIPAL_TOKEN_AMOUNT_MINTED
            : amountToSend;
        uint256 prevTotalSupply = aPar.totalSupply();
        vm.startPrank(users.alice);

        _sendToken(aBridgeableToken, address(bBridgeableToken), bEid, sendPrincipalToken, amountToSend, users.alice);

        assertEq(aPar.balanceOf(users.alice), INITIAL_BALANCE - amountToSend);
        assertEq(aPar.balanceOf(address(aBridgeableToken)), expectedPrincipalTokenAmountLocked);
        assertEq(aPar.totalSupply(), prevTotalSupply - expectedPrincipalTokenAmountBurned);
        assertEq(aBridgeableToken.balanceOf(users.alice), 0);
        assertEq(aBridgeableToken.getCurrentDailyCreditAmount(), 0);
        assertEq(aBridgeableToken.getCurrentDailyDebitAmount(), amountToSend);
        assertEq(aBridgeableToken.getCreditDebitBalance(), -int256(amountToSend));
        assertEq(aBridgeableToken.getMaxDebitableAmount(), DEFAULT_DAILY_DEBIT_LIMIT - amountToSend);

        assertEq(bPar.balanceOf(users.alice), INITIAL_BALANCE + expectedReceivedAmount);
        assertEq(bPar.balanceOf(users.feesRecipient), expectedFeesAmount);
        assertEq(bBridgeableToken.balanceOf(users.alice), 0);
        assertEq(bBridgeableToken.getPrincipalTokenAmountMinted(), amountToSend);
        assertEq(bBridgeableToken.getCurrentDailyCreditAmount(), amountToSend);
        assertEq(bBridgeableToken.getCurrentDailyDebitAmount(), 0);
        assertEq(bBridgeableToken.getCreditDebitBalance(), int256(amountToSend));
        assertEq(bBridgeableToken.getMaxCreditableAmount(), DEFAULT_DAILY_CREDIT_LIMIT - amountToSend);
    }

    modifier getLzPar() {
        vm.startPrank(users.owner);
        /// @dev By setting the daily credit limit to 0, we can only mint bLz-PAR
        bBridgeableToken.setDailyCreditLimit(0);

        /// @dev recieve bLz-PAR
        vm.startPrank(users.alice);
        _sendToken(
            aBridgeableToken,
            address(bBridgeableToken),
            bEid,
            sendPrincipalToken,
            DEFAULT_DAILY_DEBIT_LIMIT,
            users.alice
        );
        _;
    }

    function test_Send_LzPAR_Receive_PAR(uint256 amountToSend) external getLzPar {
        vm.startPrank(users.alice);
        uint256 bLzParAmount = _serializeAmountForOFT(DEFAULT_DAILY_DEBIT_LIMIT);
        uint256 aParAliceBalance = INITIAL_BALANCE - bLzParAmount;
        amountToSend = _boundBridgeAmount(amountToSend, 1e18, bLzParAmount);

        assertEq(aPar.balanceOf(users.alice), aParAliceBalance);
        assertEq(bPar.balanceOf(users.alice), INITIAL_BALANCE);
        assertEq(bBridgeableToken.balanceOf(users.alice), bLzParAmount);

        _sendToken(bBridgeableToken, address(aBridgeableToken), aEid, sendLzToken, amountToSend, users.alice);

        assertEq(aPar.balanceOf(users.alice), aParAliceBalance + amountToSend);
        assertEq(aPar.balanceOf(users.feesRecipient), 0);

        assertEq(aBridgeableToken.balanceOf(users.alice), 0);
        assertEq(aBridgeableToken.getCurrentDailyDebitAmount(), bLzParAmount);
        assertEq(aBridgeableToken.getCurrentDailyCreditAmount(), amountToSend);
        assertEq(aBridgeableToken.getCreditDebitBalance(), int256(amountToSend) - int256(bLzParAmount));

        assertEq(bPar.balanceOf(users.alice), INITIAL_BALANCE);
        assertEq(bPar.balanceOf(users.feesRecipient), 0);
        assertEq(bBridgeableToken.balanceOf(users.alice), bLzParAmount - amountToSend);
        assertEq(bBridgeableToken.getCurrentDailyCreditAmount(), 0);
        assertEq(bBridgeableToken.getCurrentDailyDebitAmount(), 0);
        assertEq(bBridgeableToken.getCreditDebitBalance(), 0);
    }

    modifier reachGlobalCreditLimit() {
        vm.startPrank(users.owner);
        /// @dev By setting the credit daily limit to 0, we direclty reach the global credit limit
        bBridgeableToken.setGlobalCreditLimit(0);
        _;
    }

    function test_ReachGlobalCreditLimit_ShouldReceiveLzPAR(uint256 amountToSend) external reachGlobalCreditLimit {
        amountToSend = _boundBridgeAmount(amountToSend, 1e18, DEFAULT_DAILY_DEBIT_LIMIT);
        vm.startPrank(users.alice);
        _sendToken(aBridgeableToken, address(bBridgeableToken), bEid, sendPrincipalToken, amountToSend, users.alice);

        assertEq(aPar.balanceOf(users.alice), INITIAL_BALANCE - amountToSend);
        assertEq(aBridgeableToken.balanceOf(users.alice), 0);
        assertEq(aBridgeableToken.getCurrentDailyDebitAmount(), amountToSend);
        assertEq(aBridgeableToken.getCurrentDailyCreditAmount(), 0);
        assertEq(aBridgeableToken.getCreditDebitBalance(), -int256(amountToSend));

        assertEq(bPar.balanceOf(users.alice), INITIAL_BALANCE);
        assertEq(bPar.balanceOf(users.feesRecipient), 0);
        assertEq(bBridgeableToken.balanceOf(users.alice), amountToSend);
        assertEq(bBridgeableToken.getCurrentDailyCreditAmount(), 0);
        assertEq(bBridgeableToken.getCurrentDailyDebitAmount(), 0);
        assertEq(bBridgeableToken.getCreditDebitBalance(), 0);
    }

    modifier reachDailyCreditLimit() {
        vm.startPrank(users.owner);
        /// @dev By setting the daily credit limit to 0, we direclty reach the limit.
        bBridgeableToken.setDailyCreditLimit(0);
        _;
    }

    function test_ReachDailyCreditLimit_ShouldReceiveLzPAR(uint256 amountToSend) external reachDailyCreditLimit {
        amountToSend = _boundBridgeAmount(amountToSend, 1e18, DEFAULT_DAILY_DEBIT_LIMIT);
        vm.startPrank(users.alice);
        _sendToken(aBridgeableToken, address(bBridgeableToken), bEid, sendPrincipalToken, amountToSend, users.alice);

        assertEq(aPar.balanceOf(users.alice), INITIAL_BALANCE - amountToSend);
        assertEq(aBridgeableToken.balanceOf(users.alice), 0);
        assertEq(aBridgeableToken.getCurrentDailyDebitAmount(), amountToSend);
        assertEq(aBridgeableToken.getCurrentDailyCreditAmount(), 0);
        assertEq(aBridgeableToken.getCreditDebitBalance(), -int256(amountToSend));

        assertEq(bPar.balanceOf(users.alice), INITIAL_BALANCE);
        assertEq(bPar.balanceOf(users.feesRecipient), 0);
        assertEq(bBridgeableToken.balanceOf(users.alice), amountToSend);
        assertEq(bBridgeableToken.getCurrentDailyCreditAmount(), 0);
        assertEq(bBridgeableToken.getCurrentDailyDebitAmount(), 0);
        assertEq(bBridgeableToken.getCreditDebitBalance(), 0);
    }

    modifier reachDailyDebitLimit() {
        vm.startPrank(users.owner);
        /// @dev By setting the daily debit limit to 0, we direclty reach the limit.
        aBridgeableToken.setDailyDebitLimit(0);
        _;
    }

    function test_RevertWhen_DailyDebitLimitReached(uint256 amountToSend) external reachDailyDebitLimit {
        amountToSend = _boundBridgeAmount(amountToSend, DEFAULT_DAILY_DEBIT_LIMIT, uint256(type(int256).max));

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
        vm.expectRevert(ErrorsLib.DailyDebitLimitReached.selector);
        aBridgeableToken.send{ value: fees.nativeFee }(sendParam, fees, payable(users.alice));
    }

    modifier reachGlobalDebitLimit() {
        vm.startPrank(users.owner);
        /// @dev By setting the global debit limit to 0, we direclty reach the limit.
        aBridgeableToken.setGlobalDebitLimit(0);
        _;
    }

    function test_RevertWhen_GlobalDebitLimitReached(uint256 amountToSend) external reachGlobalDebitLimit {
        amountToSend = _boundBridgeAmount(amountToSend, 1e18, DEFAULT_DAILY_DEBIT_LIMIT);

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
        vm.expectRevert(ErrorsLib.GlobalDebitLimitReached.selector);
        aBridgeableToken.send{ value: fees.nativeFee }(sendParam, fees, payable(users.alice));
    }

    modifier setIsolateMode() {
        vm.startPrank(users.owner);
        aBridgeableToken.toggleIsolateMode();
        _;
    }

    function test_RevertWhen_InIsolateModeCreditDebitBalanceBelowZero(uint256 amountToSend) external setIsolateMode {
        amountToSend = _boundBridgeAmount(amountToSend, 1e18, DEFAULT_DAILY_DEBIT_LIMIT);

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

    modifier sendAndUpdateGlobalCreditAmount(uint256 amountToSend) {
        amountToSend = _boundBridgeAmount(amountToSend, 1e18, DEFAULT_DAILY_DEBIT_LIMIT / 10);
        uint256 expectedFeesAmount = amountToSend.percentMul(DEFAULT_FEE_RATE);
        uint256 expectedReceivedAmount = amountToSend - expectedFeesAmount;
        vm.startPrank(users.alice);
        _sendToken(aBridgeableToken, address(bBridgeableToken), bEid, sendPrincipalToken, amountToSend, users.alice);

        vm.startPrank(users.owner);
        bBridgeableToken.setGlobalCreditLimit(expectedReceivedAmount / 10);
        _;
    }

    function test_ReceivedOFT_When_GlobalCreditAmountUpdatedBelowCreditDebitBalance(
        uint256 amountToSend
    ) external sendAndUpdateGlobalCreditAmount(amountToSend) {
        amountToSend = _boundBridgeAmount(amountToSend, 1e18, DEFAULT_DAILY_DEBIT_LIMIT / 10);
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

    function test_RevertWhen_ToIsAddressZero() external {
        vm.startPrank(users.alice);
        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        SendParam memory sendParam = SendParam(
            bEid,
            addressToBytes32(address(0)),
            1e18,
            1e18,
            options,
            abi.encode(true),
            ""
        );
        MessagingFee memory fees = aBridgeableToken.quoteSend(sendParam, false);
        vm.expectRevert(ErrorsLib.AddressZero.selector);
        aBridgeableToken.send{ value: fees.nativeFee }(sendParam, fees, payable(msg.sender));
    }
}
