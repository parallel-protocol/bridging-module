// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import { SendParam, OFTReceipt } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/interfaces/IOFT.sol";
import { MessagingFee, MessagingReceipt } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFTCore.sol";

import "../Invariants.t.sol";

contract BridgeableToken_Invariants_Test is Invariants_Test {
    using OptionsBuilder for bytes;

    uint256 constant DEFAULT_MAX_BRIDGE_AMOUNT = 10e18;
    uint256 constant TOTAL_PAR_INITIAL_SUPPLY = INITIAL_BALANCE * 2;

    struct BridgeCall {
        address sendingBridgeableToken;
        address receivingBridgeableTokensContract;
        uint32 receivingEid;
        ERC20Mock principalToken;
    }

    BridgeCall[] internal bridgeableTokensContract;

    function setUp() public virtual override {
        _weightSelector(this.setFeesRate.selector, 10);
        _weightSelector(this.sendNoRevert.selector, 100);
        _weightSelector(this.getLzToken.selector, 80);
        _weightSelector(this.swapLzTokenToPrincipalTokenNoRevert.selector, 20);
        _weightSelector(this.lockPrincipalToken.selector, 20);

        super.setUp();

        bridgeableTokensContract.push(
            BridgeCall({
                sendingBridgeableToken: address(aBridgeableToken),
                receivingBridgeableTokensContract: address(bBridgeableToken),
                receivingEid: bEid,
                principalToken: aPar
            })
        );

        bridgeableTokensContract.push(
            BridgeCall({
                sendingBridgeableToken: address(bBridgeableToken),
                receivingBridgeableTokensContract: address(aBridgeableToken),
                receivingEid: aEid,
                principalToken: bPar
            })
        );
    }

    //-------------------------------------------
    // Invariants functions
    //-------------------------------------------

    function invariant_CreditDebitBalanceMatchBalances() external {
        uint256 aliceBalanceAPar = aPar.balanceOf(users.alice);
        uint256 aliceBalanceBPar = bPar.balanceOf(users.alice);

        uint256 bobBalanceAPar = aPar.balanceOf(users.bob);
        uint256 bobBalanceBPar = bPar.balanceOf(users.bob);

        uint256 feesRecipientBalanceAPar = aPar.balanceOf(users.feesRecipient);
        uint256 feesRecipientBalanceBPar = bPar.balanceOf(users.feesRecipient);

        uint256 totalAPar = aliceBalanceAPar + bobBalanceAPar + feesRecipientBalanceAPar;
        uint256 totalBPar = aliceBalanceBPar + bobBalanceBPar + feesRecipientBalanceBPar;

        assertEq(aBridgeableToken.getCreditDebitBalance(), int256(totalAPar) - int256(TOTAL_PAR_INITIAL_SUPPLY));
        assertEq(bBridgeableToken.getCreditDebitBalance(), int256(totalBPar) - int256(TOTAL_PAR_INITIAL_SUPPLY));
    }

    function invariant_ParInitialSupplyMatchParPlusLzParSupply() external {
        uint256 aliceBalanceAPar = aPar.balanceOf(users.alice);
        uint256 aliceBalanceBPar = bPar.balanceOf(users.alice);

        uint256 bobBalanceAPar = aPar.balanceOf(users.bob);
        uint256 bobBalanceBPar = bPar.balanceOf(users.bob);

        uint256 feesRecipientBalanceAPar = aPar.balanceOf(users.feesRecipient);
        uint256 feesRecipientBalanceBPar = bPar.balanceOf(users.feesRecipient);
        uint256 totalAPar = aliceBalanceAPar + bobBalanceAPar + feesRecipientBalanceAPar;
        uint256 totalBPar = aliceBalanceBPar + bobBalanceBPar + feesRecipientBalanceBPar;
        _assertTotalSupply(TOTAL_PAR_INITIAL_SUPPLY * 2, totalAPar, totalBPar);
    }

    //-------------------------------------------
    // Handlers functions
    //-------------------------------------------

    function setFeesRate(uint16 rate, uint256 bridgeSeed) external logCall("setFeesRate") {
        rate = _boundUint16(rate, 0, ContractConstantsLib.MAX_FEE);
        vm.startPrank(users.owner);
        BridgeCall memory bridgeCall = _randomBridgeableTokenContract(bridgeSeed);
        BridgeableToken(bridgeCall.sendingBridgeableToken).setFeesRate(rate);
        vm.stopPrank();
    }

    function sendNoRevert(uint256 amountToSend, uint256 bridgeSeed, bool sendPrincipalToken) external logCall("send") {
        BridgeCall memory bridgeCall = _randomBridgeableTokenContract(bridgeSeed);
        amountToSend = _boundBridgeAmount(amountToSend, 1e18, DEFAULT_MAX_BRIDGE_AMOUNT);
        _bridgeToken(amountToSend, sendPrincipalToken, bridgeCall);
    }

    function getLzToken(uint256 amountToSend, uint256 bridgeSeed) external logCall("getLzToken") {
        amountToSend = _boundBridgeAmount(amountToSend, 1e18, DEFAULT_MAX_BRIDGE_AMOUNT);
        _getLzToken(amountToSend, bridgeSeed);
    }

    function swapLzTokenToPrincipalTokenNoRevert(
        uint256 amountToSwap,
        uint256 bridgeSeed
    ) external logCall("swapLzTokenToPrincipalToken") {
        BridgeCall memory bridgeCall = _randomBridgeableTokenContract(bridgeSeed);
        BridgeableToken bridgeableToken = BridgeableToken(bridgeCall.sendingBridgeableToken);
        uint256 senderLzBalance = bridgeableToken.balanceOf(msg.sender);
        if (senderLzBalance == 0) return;
        amountToSwap = _boundBridgeAmount(amountToSwap, 1e18, senderLzBalance);
        bridgeableToken.swapLzTokenToPrincipalToken(users.alice, amountToSwap);
    }

    function lockPrincipalToken(uint256 amountToLock, uint256 bridgeSeed) external logCall("lockPrincipalToken") {
        BridgeCall memory bridgeCall = _randomBridgeableTokenContract(bridgeSeed);
        bridgeCall.principalToken.mint(address(bridgeCall.sendingBridgeableToken), amountToLock);
    }

    //-------------------------------------------
    // Internal functions
    //-------------------------------------------

    function _getLzToken(uint256 lzAmountToReceive, uint256 bridgeSeed) internal logCall("getLzToken") {
        address sender = msg.sender;
        BridgeCall memory bridgeCall = _randomBridgeableTokenContract(bridgeSeed);
        BridgeableToken bridgeableToken = BridgeableToken(bridgeCall.receivingBridgeableTokensContract);
        vm.startPrank(users.owner);
        bridgeableToken.setDailyCreditLimit(0);
        vm.stopPrank();

        vm.startPrank(sender);
        _bridgeToken(lzAmountToReceive, true, bridgeCall);

        vm.startPrank(users.owner);
        bridgeableToken.setDailyCreditLimit(DEFAULT_DAILY_CREDIT_LIMIT);
        vm.stopPrank();

        vm.startPrank(sender);
    }

    function _bridgeToken(
        uint256 amountToSend,
        bool sendPrincipalToken,
        BridgeCall memory bridgeCall
    ) internal logCall("bridgeToken") {
        BridgeableToken bridgeableToken = BridgeableToken(bridgeCall.sendingBridgeableToken);
        if (!sendPrincipalToken && bridgeableToken.balanceOf(msg.sender) < amountToSend) {
            sendPrincipalToken = true;
        }

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);

        SendParam memory sendParam = SendParam(
            bridgeCall.receivingEid,
            addressToBytes32(msg.sender),
            amountToSend,
            amountToSend,
            options,
            abi.encode(sendPrincipalToken),
            ""
        );
        MessagingFee memory fees = bridgeableToken.quoteSend(sendParam, false);
        vm.startPrank(msg.sender);
        bridgeableToken.send{ value: fees.nativeFee }(sendParam, fees, payable(msg.sender));
        verifyPackets(bridgeCall.receivingEid, addressToBytes32(address(bridgeCall.receivingBridgeableTokensContract)));
    }

    function _randomBridgeableTokenContract(uint256 seed) internal view returns (BridgeCall memory) {
        return bridgeableTokensContract[seed % bridgeableTokensContract.length];
    }

    function _assertTotalSupply(uint256 expectedTotalSupply, uint256 totalAPar, uint256 totalBPar) internal {
        uint256 aliceLzAPar = aBridgeableToken.balanceOf(users.alice);
        uint256 aliceLzBPar = bBridgeableToken.balanceOf(users.alice);
        uint256 bobBalanceLzAPar = aBridgeableToken.balanceOf(users.bob);
        uint256 bobBalanceLzBPar = bBridgeableToken.balanceOf(users.bob);
        assertEq(
            expectedTotalSupply,
            totalAPar + totalBPar + aliceLzAPar + aliceLzBPar + bobBalanceLzAPar + bobBalanceLzBPar
        );
    }
}
