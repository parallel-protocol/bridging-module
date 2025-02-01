import { EndpointId } from '@layerzerolabs/lz-definitions'
const fantomContract = {
    eid: EndpointId.FANTOM_V2_MAINNET,
    contractName: 'BridgeableToken',
}
const mainnetContract = {
    eid: EndpointId.ETHEREUM_V2_MAINNET,
    contractName: 'BridgeableToken',
}
const polygonContract = {
    eid: EndpointId.POLYGON_V2_MAINNET,
    contractName: 'BridgeableToken',
}
export default {
    contracts: [{ contract: fantomContract }, { contract: mainnetContract }, { contract: polygonContract }],
    connections: [
        {
            from: fantomContract,
            to: mainnetContract,
            config: {
                sendLibrary: '0xC17BaBeF02a937093363220b0FB57De04A535D5E',
                receiveLibraryConfig: { receiveLibrary: '0xe1Dd69A2D08dF4eA6a30a91cC061ac70F98aAbe3', gracePeriod: 0 },
                sendConfig: {
                    executorConfig: { maxMessageSize: 10000, executor: '0x2957eBc0D2931270d4a539696514b047756b3056' },
                    ulnConfig: {
                        confirmations: BigInt(25),
                        requiredDVNs: [
                            '0xe60a3959ca23a92bf5aaf992ef837ca7f828628a',
                            '0x8ddf05f9a5c488b4973897e278b58895bf87cb24',
                        ],
                        optionalDVNs: [
                            '0x31f748a368a893bdb5abb67ec95f232507601a73',
                            '0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc',
                        ],
                        optionalDVNThreshold: 1,
                    },
                },
                receiveConfig: {
                    ulnConfig: {
                        confirmations: BigInt(15),
                        requiredDVNs: [
                            '0xe60a3959ca23a92bf5aaf992ef837ca7f828628a',
                            '0x8ddf05f9a5c488b4973897e278b58895bf87cb24',
                        ],
                        optionalDVNs: [
                            '0x31f748a368a893bdb5abb67ec95f232507601a73',
                            '0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc',
                        ],
                        optionalDVNThreshold: 1,
                    },
                },
            },
        },
        {
            from: fantomContract,
            to: polygonContract,
            config: {
                sendLibrary: '0xC17BaBeF02a937093363220b0FB57De04A535D5E',
                receiveLibraryConfig: { receiveLibrary: '0xe1Dd69A2D08dF4eA6a30a91cC061ac70F98aAbe3', gracePeriod: 0 },
                sendConfig: {
                    executorConfig: { maxMessageSize: 10000, executor: '0x2957eBc0D2931270d4a539696514b047756b3056' },
                    ulnConfig: {
                        confirmations: BigInt(25),
                        requiredDVNs: [
                            '0xe60a3959ca23a92bf5aaf992ef837ca7f828628a',
                            '0x8ddf05f9a5c488b4973897e278b58895bf87cb24',
                        ],
                        optionalDVNs: [
                            '0x31f748a368a893bdb5abb67ec95f232507601a73',
                            '0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc',
                        ],
                        optionalDVNThreshold: 1,
                    },
                },
                receiveConfig: {
                    ulnConfig: {
                        confirmations: BigInt(512),
                        requiredDVNs: [
                            '0xe60a3959ca23a92bf5aaf992ef837ca7f828628a',
                            '0x8ddf05f9a5c488b4973897e278b58895bf87cb24',
                        ],
                        optionalDVNs: [
                            '0x31f748a368a893bdb5abb67ec95f232507601a73',
                            '0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc',
                        ],
                        optionalDVNThreshold: 1,
                    },
                },
            },
        },
        {
            from: mainnetContract,
            to: fantomContract,
            config: {
                sendLibrary: '0xbB2Ea70C9E858123480642Cf96acbcCE1372dCe1',
                receiveLibraryConfig: { receiveLibrary: '0xc02Ab410f0734EFa3F14628780e6e695156024C2', gracePeriod: 0 },
                sendConfig: {
                    executorConfig: { maxMessageSize: 10000, executor: '0x173272739Bd7Aa6e4e214714048a9fE699453059' },
                    ulnConfig: {
                        confirmations: BigInt(15),
                        requiredDVNs: [
                            '0x589dedbd617e0cbcb916a9223f4d1300c294236b',
                            '0x8ddf05f9a5c488b4973897e278b58895bf87cb24',
                        ],
                        optionalDVNs: [
                            '0xa59ba433ac34d2927232918ef5b2eaafcf130ba5',
                            '0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc',
                        ],
                        optionalDVNThreshold: 1,
                    },
                },
                receiveConfig: {
                    ulnConfig: {
                        confirmations: BigInt(25),
                        requiredDVNs: [
                            '0x589dedbd617e0cbcb916a9223f4d1300c294236b',
                            '0x8ddf05f9a5c488b4973897e278b58895bf87cb24',
                        ],
                        optionalDVNs: [
                            '0xa59ba433ac34d2927232918ef5b2eaafcf130ba5',
                            '0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc',
                        ],
                        optionalDVNThreshold: 1,
                    },
                },
            },
        },
        {
            from: polygonContract,
            to: fantomContract,
            config: {
                sendLibrary: '0x6c26c61a97006888ea9E4FA36584c7df57Cd9dA3',
                receiveLibraryConfig: { receiveLibrary: '0x1322871e4ab09Bc7f5717189434f97bBD9546e95', gracePeriod: 0 },
                sendConfig: {
                    executorConfig: { maxMessageSize: 10000, executor: '0xCd3F213AD101472e1713C72B1697E727C803885b' },
                    ulnConfig: {
                        confirmations: BigInt(512),
                        requiredDVNs: [
                            '0x23de2fe932d9043291f870324b74f820e11dc81a',
                            '0x8ddf05f9a5c488b4973897e278b58895bf87cb24',
                        ],
                        optionalDVNs: [
                            '0x31f748a368a893bdb5abb67ec95f232507601a73',
                            '0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc',
                        ],
                        optionalDVNThreshold: 1,
                    },
                },
                receiveConfig: {
                    ulnConfig: {
                        confirmations: BigInt(25),
                        requiredDVNs: [
                            '0x23de2fe932d9043291f870324b74f820e11dc81a',
                            '0x8ddf05f9a5c488b4973897e278b58895bf87cb24',
                        ],
                        optionalDVNs: [
                            '0x31f748a368a893bdb5abb67ec95f232507601a73',
                            '0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc',
                        ],
                        optionalDVNThreshold: 1,
                    },
                },
            },
        },
        {
            from: mainnetContract,
            to: polygonContract,
            config: {
                sendLibrary: '0xbB2Ea70C9E858123480642Cf96acbcCE1372dCe1',
                receiveLibraryConfig: { receiveLibrary: '0xc02Ab410f0734EFa3F14628780e6e695156024C2', gracePeriod: 0 },
                sendConfig: {
                    executorConfig: { maxMessageSize: 10000, executor: '0x173272739Bd7Aa6e4e214714048a9fE699453059' },
                    ulnConfig: {
                        confirmations: BigInt(15),
                        requiredDVNs: [
                            '0x589dedbd617e0cbcb916a9223f4d1300c294236b',
                            '0x8ddf05f9a5c488b4973897e278b58895bf87cb24',
                        ],
                        optionalDVNs: [
                            '0xa59ba433ac34d2927232918ef5b2eaafcf130ba5',
                            '0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc',
                        ],
                        optionalDVNThreshold: 1,
                    },
                },
                receiveConfig: {
                    ulnConfig: {
                        confirmations: BigInt(512),
                        requiredDVNs: [
                            '0x589dedbd617e0cbcb916a9223f4d1300c294236b',
                            '0x8ddf05f9a5c488b4973897e278b58895bf87cb24',
                        ],
                        optionalDVNs: [
                            '0xa59ba433ac34d2927232918ef5b2eaafcf130ba5',
                            '0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc',
                        ],
                        optionalDVNThreshold: 1,
                    },
                },
            },
        },
        {
            from: polygonContract,
            to: mainnetContract,
            config: {
                sendLibrary: '0x6c26c61a97006888ea9E4FA36584c7df57Cd9dA3',
                receiveLibraryConfig: { receiveLibrary: '0x1322871e4ab09Bc7f5717189434f97bBD9546e95', gracePeriod: 0 },
                sendConfig: {
                    executorConfig: { maxMessageSize: 10000, executor: '0xCd3F213AD101472e1713C72B1697E727C803885b' },
                    ulnConfig: {
                        confirmations: BigInt(512),
                        requiredDVNs: [
                            '0x23de2fe932d9043291f870324b74f820e11dc81a',
                            '0x8ddf05f9a5c488b4973897e278b58895bf87cb24',
                        ],
                        optionalDVNs: [
                            '0x31f748a368a893bdb5abb67ec95f232507601a73',
                            '0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc',
                        ],
                        optionalDVNThreshold: 1,
                    },
                },
                receiveConfig: {
                    ulnConfig: {
                        confirmations: BigInt(15),
                        requiredDVNs: [
                            '0x23de2fe932d9043291f870324b74f820e11dc81a',
                            '0x8ddf05f9a5c488b4973897e278b58895bf87cb24',
                        ],
                        optionalDVNs: [
                            '0x31f748a368a893bdb5abb67ec95f232507601a73',
                            '0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc',
                        ],
                        optionalDVNThreshold: 1,
                    },
                },
            },
        },
    ],
}
