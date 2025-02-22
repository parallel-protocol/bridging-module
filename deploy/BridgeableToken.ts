import assert from 'assert'

import { readFileSync } from 'fs-extra'
import { type DeployFunction } from 'hardhat-deploy/types'

import { BridgeableToken } from '../typechain-types/contracts/tokens/BridgeableToken'

import { BridgeableTokenConfig } from './utils/types'

const contractName = 'BridgeableToken'

const deploy: DeployFunction = async (hre) => {
    const { getNamedAccounts, deployments } = hre

    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()

    assert(deployer, 'Missing named deployer account')

    console.log(`Network: ${hre.network.name}`)
    console.log(`Deployer: ${deployer}`)

    const config: BridgeableTokenConfig = JSON.parse(
        readFileSync(`./deploy/config/${hre.network.name}/config.json`).toString()
    )

    const configParams: BridgeableToken.ConfigParamsStruct = {
        dailyCreditLimit: config.dailyCreditLimit,
        globalCreditLimit: config.globalCreditLimit,
        dailyDebitLimit: config.dailyDebitLimit,
        globalDebitLimit: config.globalDebitLimit,
        initialPrincipalTokenAmountMinted: config.initialPrincipalTokenAmountMinted,
        initialCreditDebitBalance: config.initialCreditDebitBalance,
        feesRecipient: config.feesRecipient,
        feesRate: config.feesRate,
        isIsolateMode: config.isIsolateMode,
    }

    // This is an external deployment pulled in from @layerzerolabs/lz-evm-sdk-v2
    //
    // @layerzerolabs/toolbox-hardhat takes care of plugging in the external deployments
    // from @layerzerolabs packages based on the configuration in your hardhat config
    //
    // For this to work correctly, your network config must define an eid property
    // set to `EndpointId` as defined in @layerzerolabs/lz-definitions
    //
    // For example:
    //
    // networks: {
    //   fuji: {
    //     ...
    //     eid: EndpointId.AVALANCHE_V2_TESTNET
    //   }
    // }
    console.log('Deploying BridgeableToken...')
    const endpointV2Deployment = await hre.deployments.get('EndpointV2')

    const bridgeableToken = await deploy(contractName, {
        from: deployer,
        args: [
            config.lzName,
            config.lzSymbol,
            config.principalTokenAddress,
            endpointV2Deployment.address,
            deployer,
            configParams,
        ],
        log: true,
        skipIfAlreadyDeployed: false,
    })

    console.log(`Deployed contract: ${contractName}, network: ${hre.network.name}, address: ${bridgeableToken.address}`)
}

deploy.tags = [contractName]

export default deploy
