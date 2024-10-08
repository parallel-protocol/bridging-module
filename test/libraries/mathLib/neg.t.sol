// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import "test/Base.t.sol";

import { MathLib } from "contracts/libraries/MathLib.sol";

contract MathLib_Neg_Test is Base_Test {
    using MathLib for uint256;

    function test_neg(uint256 value) external {
        vm.assume(value > 0 && value < uint256(type(int256).max));
        assertEq(value.neg(), -int256(value));
    }

    function test_neg_zero() external {
        uint256 value = 0;
        assertEq(value.neg(), 0);
    }
}
