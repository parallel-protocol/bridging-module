import { EndpointId } from '@layerzerolabs/lz-definitions'

const amoyContract = {
    eid: EndpointId.AMOY_V2_TESTNET,
    contractName: 'BridgeableToken',
}
const arbSepoliaContract = {
    eid: EndpointId.ARBSEP_V2_TESTNET,
    contractName: 'BridgeableToken',
}
const sepoliaContract = {
    eid: EndpointId.SEPOLIA_V2_TESTNET,
    contractName: 'BridgeableToken',
}
export default {
    contracts: [{ contract: amoyContract }, { contract: arbSepoliaContract }, { contract: sepoliaContract }],
    connections: [
        {
            from: amoyContract,
            to: arbSepoliaContract,
        },
        {
            from: amoyContract,
            to: sepoliaContract,
        },
        {
            from: arbSepoliaContract,
            to: amoyContract,
        },
        {
            from: arbSepoliaContract,
            to: sepoliaContract,
        },
        {
            from: sepoliaContract,
            to: amoyContract,
        },
        {
            from: sepoliaContract,
            to: arbSepoliaContract,
        },
    ],
}
