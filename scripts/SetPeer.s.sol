// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import { console2 } from "@forge-std/console2.sol";

import "./Base.s.sol";

import { BridgeableToken } from "contracts/tokens/BridgeableToken.sol";

contract SetPeerScript is BaseScript {
    /// @dev to get the eid of the network to add check the following link
    /// https://docs.layerzero.network/v2/developers/evm/technical-reference/deployed-contracts) for others networks

    struct Peer {
        address addr;
        uint32 eid;
    }

    function run() external broadcast {
        BridgeableToken bridgeableToken = BridgeableToken(0x8932eAD0662b079e12D0ca5005f7123e0dF1b3fd);

        Peer[] memory peers = new Peer[](2);

        peers[0] = Peer(0x1b03d006a47dF53B440B9a94aF88f38F63583342, 40161);
        peers[1] = Peer(0x27B8907330ca7C130d4C125aDDc7588520E8208a, 40267);

        uint256 i = 0;
        for (; i < peers.length; ++i) {
            bytes32 peerInBytes = addressToBytes32(peers[i].addr);
            uint32 peerEid = peers[i].eid;
            bridgeableToken.setPeer(peerEid, peerInBytes);
            console2.log("Peer set", peerEid, peers[i].addr);
        }
    }
}
