// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import { SendParam, OFTReceipt } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/interfaces/IOFT.sol";
import { MessagingFee, MessagingReceipt } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFTCore.sol";

import "test/Base.t.sol";

/// @notice Common logic needed by all integration tests, both concrete and fuzz tests.
abstract contract Integrations_Test is Base_Test {
    using OptionsBuilder for bytes;

    BridgeableToken.ConfigParams defaultConfigParams;

    modifier deployBridgeableTokenToBurnOnSend(uint256 principalTokenAmountMinted) {
        defaultConfigParams = BridgeableToken.ConfigParams({
            dailyCreditLimit: DEFAULT_DAILY_CREDIT_LIMIT,
            globalCreditLimit: DEFAULT_GLOBAL_CREDIT_LIMIT,
            dailyDebitLimit: DEFAULT_DAILY_DEBIT_LIMIT,
            globalDebitLimit: DEFAULT_GLOBAL_DEBIT_LIMIT,
            initialPrincipalTokenAmountMinted: principalTokenAmountMinted,
            initialCreditDebitBalance: DEFAULT_NET_BRIDGED_AMOUNT,
            feesRecipient: users.feesRecipient,
            feesRate: DEFAULT_FEE_RATE,
            isIsolateMode: false
        });
        aBridgeableToken = _deployBridgeableToken(
            "aBridgeableToken",
            "aLz-Par",
            "aLzPAR",
            address(aPar),
            address(endpoints[aEid]),
            address(users.owner),
            defaultConfigParams
        );
        vm.startPrank(users.owner);
        // config and wire the ofts
        address[] memory bridgeableTokens = new address[](2);
        bridgeableTokens[0] = address(aBridgeableToken);
        bridgeableTokens[1] = address(bBridgeableToken);
        wireOApps(bridgeableTokens);
        vm.startPrank(users.alice);
        aPar.approve(address(aBridgeableToken), INITIAL_BALANCE);
        _;
    }

    function setUp() public virtual override {
        Base_Test.setUp();

        setUpEndpoints(2, LibraryType.UltraLightNode);

        vm.startPrank(users.owner);
        defaultConfigParams = BridgeableToken.ConfigParams({
            dailyCreditLimit: DEFAULT_DAILY_CREDIT_LIMIT,
            globalCreditLimit: DEFAULT_GLOBAL_CREDIT_LIMIT,
            dailyDebitLimit: DEFAULT_DAILY_DEBIT_LIMIT,
            globalDebitLimit: DEFAULT_GLOBAL_DEBIT_LIMIT,
            initialPrincipalTokenAmountMinted: DEFAULT_PRINCIPAL_TOKEN_AMOUNT_MINTED,
            initialCreditDebitBalance: DEFAULT_NET_BRIDGED_AMOUNT,
            feesRecipient: users.feesRecipient,
            feesRate: DEFAULT_FEE_RATE,
            isIsolateMode: false
        });
        aBridgeableToken = _deployBridgeableToken(
            "aBridgeableToken",
            "aLz-Par",
            "aLzPAR",
            address(aPar),
            address(endpoints[aEid]),
            address(users.owner),
            defaultConfigParams
        );
        bBridgeableToken = _deployBridgeableToken(
            "bBridgeableToken",
            "bLz-Par",
            "bLzPAR",
            address(bPar),
            address(endpoints[bEid]),
            address(users.owner),
            defaultConfigParams
        );

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
        bool isPrincipalTokenSent,
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
            abi.encode(isPrincipalTokenSent),
            ""
        );
        MessagingFee memory fees = bridgeableTokenSending.quoteSend(sendParam, false);
        bridgeableTokenSending.send{ value: fees.nativeFee }(sendParam, fees, payable(msgSender));
        verifyPackets(eidReceiver, bridgeableTokenReceiver);
    }
}
