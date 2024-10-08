// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import "./Base.s.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { SendParam } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/interfaces/IOFT.sol";
import { MessagingFee } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFTCore.sol";
import { OptionsBuilder } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";

import { BridgeableToken } from "contracts/tokens/BridgeableToken.sol";

contract BridgeTokenScript is BaseScript {
    using OptionsBuilder for bytes;

    uint256 sendAmount = 50e18; // 30 tokens
    bool sendPrincipalToken = true;
    uint32 eidReceiver = 40267; // amoy (check:
    // https://docs.layerzero.network/v2/developers/evm/technical-reference/deployed-contracts) for others networks

    // Data are set to bridge 10 PAR from Arbitrum Sepolia to Amoy
    function run() external broadcast {
        IERC20 principalToken = IERC20(0x78C48A7d7Fc69735fDab448fe6068bbA44a920E6);

        BridgeableToken bridgeableToken = BridgeableToken(0x86AfA59fF739b5bE56Ce8a81A424af17B29668e9);

        principalToken.approve(address(bridgeableToken), sendAmount);

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        SendParam memory sendParam = SendParam(
            eidReceiver,
            addressToBytes32(broadcaster),
            sendAmount,
            sendAmount,
            options,
            abi.encode(sendPrincipalToken),
            ""
        );
        MessagingFee memory fees = bridgeableToken.quoteSend(sendParam, false);
        bridgeableToken.send{ value: fees.nativeFee }(sendParam, fees, payable(broadcaster));
    }
}
