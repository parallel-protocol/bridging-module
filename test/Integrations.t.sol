// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import { SendParam, OFTReceipt } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/interfaces/IOFT.sol";
import { MessagingFee, MessagingReceipt } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFTCore.sol";
import { MessagingReceipt } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OAppSender.sol";

import "test/Base.t.sol";

/// @notice Common logic needed by all integration tests, both concrete and fuzz tests.
abstract contract Integrations_Test is Base_Test {
    using OptionsBuilder for bytes;

    BridgeableToken.ConfigParams defaultConfigParams;

    function setUp() public virtual override {
        Base_Test.setUp();

        setUpEndpoints(2, LibraryType.UltraLightNode);

        vm.startPrank(users.owner);
        defaultConfigParams = BridgeableToken.ConfigParams({
            mintDailyLimit: DEFAULT_MINT_DAILY_LIMIT,
            globalMintLimit: DEFAULT_GLOBAL_MINT_LIMIT,
            burnDailyLimit: DEFAULT_BURN_DAILY_LIMIT,
            globalBurnLimit: DEFAULT_GLOBAL_BURN_LIMIT,
            feesRecipient: users.feesRecipient,
            feesRate: DEFAULT_FEE_RATE,
            isIsolateMode: false
        });
        aBridgeableToken = _deployBridgeableToken(
            "aLz-Par",
            "aLzPAR",
            address(aPar),
            address(endpoints[aEid]),
            address(users.owner),
            defaultConfigParams
        );
        vm.label({ account: address(aBridgeableToken), newLabel: "aBridgeableToken" });

        bBridgeableToken = _deployBridgeableToken(
            "bLz-Par",
            "bLzPAR",
            address(bPar),
            address(endpoints[bEid]),
            address(users.owner),
            defaultConfigParams
        );
        vm.label({ account: address(bBridgeableToken), newLabel: "bBridgeableToken" });
        // config and wire the ofts
        address[] memory bridgeableTokens = new address[](2);
        bridgeableTokens[0] = address(aBridgeableToken);
        bridgeableTokens[1] = address(bBridgeableToken);
        wireOApps(bridgeableTokens);

        vm.startPrank(users.alice);
        aPar.approve(address(aBridgeableToken), INITIAL_BALANCE);
        bPar.approve(address(bBridgeableToken), INITIAL_BALANCE);
    }

    function _sendToken(
        BridgeableToken bridgeableTokenSending,
        address bridgeableTokenReceiver,
        uint32 eidReceiver,
        bool isSendingPrincipalToken,
        uint256 sendAmount,
        address msgSender
    ) internal {
        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        SendParam memory sendParam = SendParam(
            eidReceiver,
            addressToBytes32(msgSender),
            sendAmount,
            sendAmount,
            options,
            abi.encode(isSendingPrincipalToken),
            ""
        );
        MessagingFee memory fees = bridgeableTokenSending.quoteSend(sendParam, false);
        bridgeableTokenSending.send{ value: fees.nativeFee }(sendParam, fees, payable(msgSender));
        verifyPackets(eidReceiver, bridgeableTokenReceiver);
    }
}
