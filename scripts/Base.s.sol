// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import { Script, console2 } from "@forge-std/Script.sol";

contract BaseScript is Script {
    /// @dev The address of the transaction broadcaster.
    address internal broadcaster;

    modifier broadcast() {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        broadcaster = vm.addr(privateKey);
        _;
        vm.stopBroadcast();
    }

    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }
}
