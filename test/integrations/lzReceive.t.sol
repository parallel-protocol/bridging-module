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
    using PacketV1Codec for bytes;

    bool sendPrincipalToken = true;
    bool sendLzToken = false;

    bytes32 guid = hex"0000000000000000000000000000000000000000000000000000000000000001";

    function test_LzReceive_PAR_From_PrincipalToken_Burned(uint256 amountToMint) external {
        amountToMint = _boundBridgeAmount(amountToMint, 1e18, DEFAULT_MINT_DAILY_LIMIT);
        uint256 expectedFeesAmount = amountToMint.percentMul(DEFAULT_FEE_RATE);
        uint256 expectedReceivedAmount = amountToMint - expectedFeesAmount;

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        (uint256 gas, uint256 value) = OptionsHelper._parseExecutorLzReceiveOption(options);

        SendParam memory sendParam = SendParam(
            bEid,
            addressToBytes32(users.alice),
            amountToMint,
            amountToMint,
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

    function test_LzReceive_PAR_From_OFT_Burned(uint256 amountToMint) external {
        amountToMint = _boundBridgeAmount(amountToMint, 1e18, DEFAULT_MINT_DAILY_LIMIT);

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        (uint256 gas, uint256 value) = OptionsHelper._parseExecutorLzReceiveOption(options);

        SendParam memory sendParam = SendParam(
            bEid,
            addressToBytes32(users.alice),
            amountToMint,
            amountToMint,
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

        assertEq(bPar.balanceOf(users.alice), INITIAL_BALANCE + amountToMint);
        assertEq(bPar.balanceOf(users.feesRecipient), 0);
    }

    modifier reachGlobalMintLimit() {
        vm.startPrank(users.owner);
        /// @dev By setting the mint daily limit to 0, we direclty reach the global mint limit
        bBridgeableToken.setGlobalMintLimit(0);
        _;
    }

    function test_LzReceive_LzPAR(uint256 amountToMint) external reachGlobalMintLimit {
        amountToMint = _boundBridgeAmount(amountToMint, 1e18, DEFAULT_BURN_DAILY_LIMIT);

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        (uint256 gas, uint256 value) = OptionsHelper._parseExecutorLzReceiveOption(options);

        SendParam memory sendParam = SendParam(
            bEid,
            addressToBytes32(users.alice),
            amountToMint,
            amountToMint,
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
        assertEq(bBridgeableToken.balanceOf(users.alice), amountToMint);
        assertEq(bPar.balanceOf(users.feesRecipient), 0);
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
