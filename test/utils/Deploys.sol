// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

// OApp imports
import { IOAppOptionsType3, EnforcedOptionParam } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OAppOptionsType3.sol";
import { OptionsBuilder } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";


import {BridgeableToken} from "contracts/tokens/BridgeableToken.sol";

import { ERC20Mock } from "test/mocks/ERC20Mock.sol";

import { LayerZeroHelperOz5 } from "./LayerZeroHelperOz5.sol";


abstract contract Deploys is LayerZeroHelperOz5 {
    using OptionsBuilder for bytes;

    ERC20Mock aPar;
    ERC20Mock bPar;
    ERC20Mock cPar;
    BridgeableToken aBridgeableToken;
    BridgeableToken bBridgeableToken;
    BridgeableToken cBridgeableToken;


    function _deployERC20Mock(string memory name, string memory symbol, uint8 decimals) internal returns (ERC20Mock) {
        return new ERC20Mock(name, symbol, decimals);
    }

    function _deployBridgeableToken(
        string memory _name,
        string memory _symbol,
        address _innerToken,
        address _lzEndpoint,
        address _delegate,
        address _feeRecipient
    ) internal returns(BridgeableToken) {
        bytes memory constructorArgs = abi.encode(_name, _symbol, _innerToken, _lzEndpoint, _delegate, _feeRecipient);
        return BridgeableToken(_deployOApp(type(BridgeableToken).creationCode, constructorArgs));
    }
}