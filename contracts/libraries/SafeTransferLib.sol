// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {ErrorsLib} from "../libraries/ErrorsLib.sol";

interface IERC20Internal {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

/// @title SafeTransferLib
/// @author Murphy Labs
/// @custom:contact security@murphylabs.io
/// @notice Library to manage transfers of tokens, even if calls to the transfer or transferFrom functions are not
/// returning a boolean.
library SafeTransferLib {
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        if(address(token).code.length == 0) revert ErrorsLib.NoCode();

        (bool success, bytes memory data) =
            address(token).call(abi.encodeCall(IERC20.transfer, (to, value)));

        if(!success) revert ErrorsLib.TransferReverted();
        if(data.length != 0){
            if(!abi.decode(data, (bool))) revert ErrorsLib.TransferReturnedFalse();
        }
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        if(address(token).code.length == 0) revert ErrorsLib.NoCode();

        (bool success, bytes memory data) =
            address(token).call(abi.encodeCall(IERC20.transferFrom, (from, to, value)));

        if(!success) revert ErrorsLib.TransferFromReverted();
        if(data.length != 0){
            if(!abi.decode(data, (bool))) revert ErrorsLib.TransferFromReturnedFalse();
        }
    }
}