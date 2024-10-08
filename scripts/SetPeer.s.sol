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

    uint32 constant sepoliaEid = 40161;
    uint32 constant arbitrumSepoliaEid = 40231;
    uint32 constant amoyEid = 40267;

    function run() external broadcast {
        BridgeableToken bridgeableToken = BridgeableToken(0x86AfA59fF739b5bE56Ce8a81A424af17B29668e9);
        Peer[] memory peers = new Peer[](1);

        peers[0] = Peer(0xfcBA2B3fa587c46A0F3158b43cC020c5026b53A8, amoyEid);
        // peers[1] = Peer(0x7e6bc0Dc649f5E48842c881E97666C7E21d0a433, amoyEid);

        uint256 i = 0;
        for (; i < peers.length; ++i) {
            bytes32 peerInBytes = addressToBytes32(peers[i].addr);
            uint32 peerEid = peers[i].eid;
            bridgeableToken.setPeer(peerEid, peerInBytes);
            console2.log("Peer set", peerEid, peers[i].addr);
        }
    }
}
