// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import "../Integrations.t.sol";

import { OptionsHelper } from "@layerzerolabs/test-devtools-evm-foundry/contracts/OptionsHelper.sol";
import { Origin } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import { PacketV1Codec } from "@layerzerolabs/lz-evm-protocol-v2/contracts/messagelib/libs/PacketV1Codec.sol";
import { OFTMsgCodec } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/libs/OFTMsgCodec.sol";

contract BridgeableToken_LzReceive_Integrations_Test is Integrations_Test {
    using OptionsBuilder for bytes;
    using PercentageMathLib for uint256;
    using OFTMsgCodec for bytes;

    bool sendPrincipalToken = true;
    bool sendLzToken = false;

    bytes32 guid = hex"0000000000000000000000000000000000000000000000000000000000000001";

    function test_LzReceive_PAR_From_PrincipalToken_Sent(uint256 amountToSend) external {
        amountToSend = _boundBridgeAmount(amountToSend, 1e18, DEFAULT_DAILY_CREDIT_LIMIT);
        uint256 expectedFeesAmount = amountToSend.percentMul(DEFAULT_FEE_RATE);
        uint256 expectedReceivedAmount = amountToSend - expectedFeesAmount;

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        (uint256 gas, uint256 value) = OptionsHelper._parseExecutorLzReceiveOption(options);

        SendParam memory sendParam = SendParam(
            bEid,
            addressToBytes32(users.alice),
            amountToSend,
            amountToSend,
            options,
            abi.encode(sendPrincipalToken),
            ""
        );

        Origin memory origin = Origin(aEid, addressToBytes32(address(aBridgeableToken)), 1);
        (bytes memory message, ) = buildMessage(sendParam);

        address endpoint = address(bBridgeableToken.endpoint());
        vm.startPrank(endpoint);
        bBridgeableToken.lzReceive{ value: value, gas: gas }(
            origin,
            guid,
            message,
            address(bBridgeableToken),
            bytes("")
        );

        assertEq(bPar.balanceOf(users.alice), INITIAL_BALANCE + expectedReceivedAmount);
        assertEq(bPar.balanceOf(users.feesRecipient), expectedFeesAmount);
    }

    function test_LzReceive_PAR_From_OFT_Sent(uint256 amountToSend) external {
        amountToSend = _boundBridgeAmount(amountToSend, 1e18, DEFAULT_DAILY_CREDIT_LIMIT);

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        (uint256 gas, uint256 value) = OptionsHelper._parseExecutorLzReceiveOption(options);

        SendParam memory sendParam = SendParam(
            bEid,
            addressToBytes32(users.alice),
            amountToSend,
            amountToSend,
            options,
            abi.encode(sendLzToken),
            ""
        );

        Origin memory origin = Origin(aEid, addressToBytes32(address(aBridgeableToken)), 1);
        (bytes memory message, ) = buildMessage(sendParam);

        address endpoint = address(bBridgeableToken.endpoint());
        vm.startPrank(endpoint);
        bBridgeableToken.lzReceive{ value: value, gas: gas }(
            origin,
            guid,
            message,
            address(bBridgeableToken),
            bytes("")
        );

        assertEq(bPar.balanceOf(users.alice), INITIAL_BALANCE + amountToSend);
        assertEq(bPar.balanceOf(users.feesRecipient), 0);
    }

    modifier reachGlobalCreditLimit() {
        vm.startPrank(users.owner);
        /// @dev By setting the credit daily limit to 0, we direclty reach the global credit limit
        bBridgeableToken.setGlobalCreditLimit(0);
        _;
    }

    function test_LzReceive_LzPAR(uint256 amountToSend) external reachGlobalCreditLimit {
        amountToSend = _boundBridgeAmount(amountToSend, 1e18, DEFAULT_DAILY_DEBIT_LIMIT);

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        (uint256 gas, uint256 value) = OptionsHelper._parseExecutorLzReceiveOption(options);

        SendParam memory sendParam = SendParam(
            bEid,
            addressToBytes32(users.alice),
            amountToSend,
            amountToSend,
            options,
            abi.encode(sendLzToken),
            ""
        );

        Origin memory origin = Origin(aEid, addressToBytes32(address(aBridgeableToken)), 1);
        (bytes memory message, ) = buildMessage(sendParam);

        address endpoint = address(bBridgeableToken.endpoint());
        vm.startPrank(endpoint);
        bBridgeableToken.lzReceive{ value: value, gas: gas }(
            origin,
            guid,
            message,
            address(bBridgeableToken),
            bytes("")
        );

        assertEq(bPar.balanceOf(users.alice), INITIAL_BALANCE);
        assertEq(bBridgeableToken.balanceOf(users.alice), amountToSend);
        assertEq(bPar.balanceOf(users.feesRecipient), 0);
    }

    modifier reachGlobalLimitWithNegativeCreditDebitBalance() {
        vm.startPrank(users.owner);
        /// @dev Set the global limit close to daily limit to simplify test
        bBridgeableToken.setGlobalCreditLimit(100e18);

        /// @dev Birdge to make creditDebitBalance Negative

        vm.startPrank(users.alice);

        _sendToken(bBridgeableToken, address(aBridgeableToken), aEid, sendPrincipalToken, 10e18, users.alice);

        assertEq(bBridgeableToken.getCreditDebitBalance(), int256(-10e18));
        _;
    }

    function test_NotRevertWhen_CreditDebitLimitNegativeAndGlobalCreditAmountIsExceededDuringTx()
        external
        reachGlobalLimitWithNegativeCreditDebitBalance
    {
        uint256 expectedPrincipalReceived = 110e18;
        uint256 expectedOFTReceived = 1e18;
        uint256 amountToCredit = expectedPrincipalReceived + expectedOFTReceived;
        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        (uint256 gas, uint256 value) = OptionsHelper._parseExecutorLzReceiveOption(options);

        SendParam memory sendParam = SendParam(
            bEid,
            addressToBytes32(users.bob),
            amountToCredit,
            amountToCredit,
            options,
            abi.encode(sendLzToken),
            ""
        );

        Origin memory origin = Origin(aEid, addressToBytes32(address(aBridgeableToken)), 1);
        (bytes memory message, ) = buildMessage(sendParam);

        address endpoint = address(bBridgeableToken.endpoint());
        vm.startPrank(endpoint);
        bBridgeableToken.lzReceive{ value: value, gas: gas }(
            origin,
            guid,
            message,
            address(bBridgeableToken),
            bytes("")
        );

        assertEq(bPar.balanceOf(users.bob), INITIAL_BALANCE + expectedPrincipalReceived);
        assertEq(bBridgeableToken.balanceOf(users.bob), expectedOFTReceived);
    }

    function buildMessage(SendParam memory _sendParam) internal view returns (bytes memory, bytes memory) {
        (bytes memory message, ) = OFTMsgCodec.encode(
            _sendParam.to,
            uint64(_sendParam.amountLD / 1e12),
            _sendParam.composeMsg
        );
        return (message, _sendParam.extraOptions);
    }
}
