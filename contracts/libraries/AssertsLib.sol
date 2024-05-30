// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;


import {ErrorsLib} from "./ErrorsLib.sol";


function assertAddressNotZero(address _address) pure {
   if (_address == address(0)) revert ErrorsLib.AddressZero();
}