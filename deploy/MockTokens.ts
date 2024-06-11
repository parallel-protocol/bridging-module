import assert from 'assert'

import { type DeployFunction } from 'hardhat-deploy/types'

import { GAS } from './utils'

const contractName = 'ERC20Mock'

const deploy: DeployFunction = async (hre) => {
    const { getNamedAccounts, deployments } = hre

    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()

    assert(deployer, 'Missing named deployer account')

    console.log(`Network: ${hre.network.name}`)
    console.log(`Deployer: ${deployer}`)

    const { address } = await deploy('ERC20Mock', {
        from: deployer,
        args: ['MockPar', 'MPAR', 18],
        log: true,
        skipIfAlreadyDeployed: false,
        ...GAS,
    })

    console.log(`Deployed contract: ${contractName}, network: ${hre.network.name}, address: ${address}`)
}

deploy.tags = [contractName]

export default deploy

// ─ npx hardhat etherscan-verify --network amoy --api-key ENMCE3E1VTSNA4JT5GQXS96DR2J869K93T --sleep --api-url https://api-amoy.polygonscan.com/ --help
