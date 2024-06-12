// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

interface IERC20MintableAndBurnable {
    function mint(address account, uint256 amount) external;
    function burn(address account, uint256 amount) external;
}
