import { EndpointId } from '@layerzerolabs/lz-definitions'

import type { OAppOmniGraphHardhat, OmniPointHardhat } from '@layerzerolabs/toolbox-hardhat'

const sepoliaContract: OmniPointHardhat = {
    eid: EndpointId.SEPOLIA_V2_TESTNET,
    contractName: 'BridgeableToken',
}

const amoyContract: OmniPointHardhat = {
    eid: EndpointId.AMOY_V2_TESTNET,
    contractName: 'BridgeableToken',
}

const arbitrumSepoliaContract: OmniPointHardhat = {
    eid: EndpointId.ARBSEP_V2_TESTNET,
    contractName: 'BridgeableToken',
}

const config: OAppOmniGraphHardhat = {
    contracts: [
        {
            contract: sepoliaContract,
        },
        {
            contract: amoyContract,
        },
        {
            contract: arbitrumSepoliaContract,
        },
    ],
    connections: [
        {
            from: arbitrumSepoliaContract,
            to: sepoliaContract,
        },
        {
            from: arbitrumSepoliaContract,
            to: amoyContract,
        },
        {
            from: sepoliaContract,
            to: arbitrumSepoliaContract,
        },
        {
            from: sepoliaContract,
            to: amoyContract,
        },
        {
            from: amoyContract,
            to: sepoliaContract,
        },
        {
            from: amoyContract,
            to: arbitrumSepoliaContract,
        },
    ],
}

export default config
