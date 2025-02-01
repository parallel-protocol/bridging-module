// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

// OApp imports
import { IOAppOptionsType3, EnforcedOptionParam } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OAppOptionsType3.sol";
import { OptionsBuilder } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";

import { BridgeableToken } from "contracts/tokens/BridgeableToken.sol";

import { ERC20Mock } from "test/mocks/ERC20Mock.sol";

import { LayerZeroHelperOz5 } from "./LayerZeroHelperOz5.sol";

abstract contract Deploys is LayerZeroHelperOz5 {
    using OptionsBuilder for bytes;

    ERC20Mock aPar;
    ERC20Mock bPar;
    BridgeableToken aBridgeableToken;
    BridgeableToken bBridgeableToken;

    function _deployERC20Mock(string memory name, string memory symbol, uint8 decimals) internal returns (ERC20Mock) {
        return new ERC20Mock(name, symbol, decimals);
    }

    function _deployBridgeableToken(
        string memory _label,
        string memory _name,
        string memory _symbol,
        address _principalToken,
        address _lzEndpoint,
        address _delegate,
        BridgeableToken.ConfigParams memory _configParams
    ) internal returns (BridgeableToken) {
        BridgeableToken bridgeableToken = BridgeableToken(
            _deployOApp(
                type(BridgeableToken).creationCode,
                abi.encode(_name, _symbol, _principalToken, _lzEndpoint, _delegate, _configParams)
            )
        );
        vm.label({ account: address(bridgeableToken), newLabel: _label });
        return bridgeableToken;
    }
}
