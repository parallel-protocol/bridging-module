// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import { IERC20, SafeTransferLib } from "contracts/libraries/SafeTransferLib.sol";
import { ErrorsLib } from "contracts/libraries/ErrorsLib.sol";

import "test/Base.t.sol";

/// @dev Token not returning any boolean on transfer and transferFrom.
contract ERC20WithoutBoolean {
    mapping(address => uint256) public balanceOf;

    function transfer(address to, uint256 amount) public {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
    }

    function transferFrom(address from, address to, uint256 amount) public {
        // Skip allowance check.
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
    }

    function setBalance(address account, uint256 amount) public {
        balanceOf[account] = amount;
    }
}

/// @dev Token returning false on transfer and transferFrom.
contract ERC20WithBooleanAlwaysFalse {
    mapping(address => uint256) public balanceOf;

    function transfer(address to, uint256 amount) public returns (bool failure) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        failure = false; // To silence warning.
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool failure) {
        // Skip allowance check.
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        failure = false; // To silence warning.
    }

    function setBalance(address account, uint256 amount) public {
        balanceOf[account] = amount;
    }
}

contract SafeTransferLibSetup is Base_Test {
    using SafeTransferLib for *;

    ERC20WithoutBoolean public tokenWithoutBoolean;
    ERC20WithBooleanAlwaysFalse public tokenWithBooleanAlwaysFalse;

    function setUp() public override {
        tokenWithoutBoolean = new ERC20WithoutBoolean();
        tokenWithBooleanAlwaysFalse = new ERC20WithBooleanAlwaysFalse();
    }

    function safeTransfer(address token, address to, uint256 amount) external {
        IERC20(token).safeTransfer(to, amount);
    }

    function safeTransferFrom(address token, address from, address to, uint256 amount) external {
        IERC20(token).safeTransferFrom(from, to, amount);
    }
}
