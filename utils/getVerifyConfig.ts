type VerifyConfig = {
    etherscan: {
        apiUrl: string
        apiKey: string | undefined
    }
}

export const getVerifyConfig = (network: string): VerifyConfig => {
    const config: VerifyConfig = { etherscan: { apiUrl: '', apiKey: undefined } }
    switch (network) {
        case 'sepolia': {
            config.etherscan = {
                apiUrl: 'https://api-sepolia.etherscan.io/',
                apiKey: process.env.ETHERSCAN_API_KEY,
            }
            break
        }
        case 'amoy': {
            config.etherscan = {
                apiUrl: 'https://api-amoy.polygonscan.com/',
                apiKey: process.env.POLYSCAN_API_KEY,
            }
            break
        }
        case 'arbSepolia': {
            config.etherscan = {
                apiUrl: 'https://api-sepolia.arbiscan.io/',
                apiKey: process.env.ARBISCAN_API_KEY,
            }
            break
        }
        default: {
            throw new Error(`${network} Network Verify not configured`)
        }
    }
    return config
}
