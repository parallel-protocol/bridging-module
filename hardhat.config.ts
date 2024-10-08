// Get the environment configuration from .env file
//
// To make use of automatic environment setup:
// - Duplicate .env.example file and name it .env
// - Fill in the environment variables
import 'dotenv/config'

import '@typechain/hardhat'
import '@nomicfoundation/hardhat-ethers'

import 'hardhat-deploy'
import 'hardhat-contract-sizer'
import '@nomiclabs/hardhat-ethers'
import '@layerzerolabs/toolbox-hardhat'
import { HardhatUserConfig, HttpNetworkAccountsUserConfig } from 'hardhat/types'

import { EndpointId } from '@layerzerolabs/lz-definitions'

import { getRpcURL } from './utils/getRpcURL'
import { getVerifyConfig } from './utils/getVerifyConfig'

// Set your preferred authentication method
//
// If you prefer using a mnemonic, set a MNEMONIC environment variable
// to a valid mnemonic
const MNEMONIC = process.env.MNEMONIC

// If you prefer to be authenticated using a private key, set a PRIVATE_KEY environment variable
const PRIVATE_KEY = process.env.PRIVATE_KEY

const accounts: HttpNetworkAccountsUserConfig | undefined = MNEMONIC
    ? { mnemonic: MNEMONIC }
    : PRIVATE_KEY
      ? [PRIVATE_KEY]
      : undefined

if (accounts == null) {
    console.warn(
        'Could not find MNEMONIC or PRIVATE_KEY environment variables. It will not be possible to execute transactions in your example.'
    )
}

const config: HardhatUserConfig = {
    solidity: {
        compilers: [
            {
                version: '0.8.22',
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 1000,
                    },
                },
            },
        ],
    },
    networks: {
        sepolia: {
            eid: EndpointId.SEPOLIA_V2_TESTNET,
            url: getRpcURL('sepolia'),
            accounts,
            verify: getVerifyConfig('sepolia'),
        },
        amoy: {
            eid: EndpointId.AMOY_V2_TESTNET,
            url: getRpcURL('amoy'),
            accounts,
            verify: getVerifyConfig('amoy'),
        },
        arbSepolia: {
            eid: EndpointId.ARBSEP_V2_TESTNET,
            url: getRpcURL('arbSepolia'),
            accounts,
            verify: getVerifyConfig('arbSepolia'),
        },
    },
    namedAccounts: {
        deployer: {
            default: 0,
        },
    },
}

export default config
