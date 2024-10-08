type VerifyConfig = {
    etherscan: {
        apiUrl: string
        apiKey: string
    }
}

export const getVerifyConfig = (network: string): VerifyConfig => {
    switch (network) {
        case 'sepolia': {
            if (!process.env.ETHERSCAN_API_KEY) throw new Error('ETHERSCAN_API_KEY is not set')
            return {
                etherscan: {
                    apiUrl: 'https://api-sepolia.etherscan.io',
                    apiKey: process.env.ETHERSCAN_API_KEY,
                },
            }
        }
        case 'amoy': {
            if (!process.env.POLYSCAN_API_KEY) throw new Error('POLYSCAN_API_KEY is not set')
            return {
                etherscan: {
                    apiUrl: 'https://api-amoy.polygonscan.com',
                    apiKey: process.env.POLYSCAN_API_KEY,
                },
            }
        }
        case 'arbSepolia': {
            if (!process.env.ARBISCAN_API_KEY) throw new Error('ARBISCAN_API_KEY is not set')
            return {
                etherscan: {
                    apiUrl: 'https://api-sepolia.arbiscan.io',
                    apiKey: process.env.ARBISCAN_API_KEY,
                },
            }
        }
        default: {
            throw new Error(`${network} Network Verify not configured`)
        }
    }
}
