// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import "test/Base.t.sol";

import { PercentageMathLib } from "contracts/libraries/PercentageMathLib.sol";

contract PercentageMathLib_PercentMul_Test is Base_Test {
    using PercentageMathLib for uint256;

    function test_PercentMul() external {
        uint256 amount = 100e18;
        assertEq(amount.percentMul(1000), 1e19); // 10%
        assertEq(amount.percentMul(100_000), 1e21); // 1000%
    }

    function test_PercentMul_RevertWhen_OverFlow() external {
        uint256 amount = type(uint256).max;
        uint256 percentage = 1000; // 10%
        vm.expectRevert();
        amount.percentMul(percentage);
    }
}
