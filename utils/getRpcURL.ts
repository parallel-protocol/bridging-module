export const getRpcURL = (network: string): string => {
    const apiKey = process.env.ALCHEMY_API_KEY
    if (!apiKey) throw new Error('ALCHEMY_API_KEY is not set')

    switch (network) {
        case 'sepolia': {
            return `https://eth-sepolia.g.alchemy.com/v2/${apiKey}`
        }
        case 'amoy': {
            return `https://polygon-amoy.g.alchemy.com/v2/${apiKey}`
        }
        case 'arbSepolia': {
            return `https://arb-sepolia.g.alchemy.com/v2/${apiKey}`
        }
        default: {
            throw new Error(`${network} Network RPC not configured`)
        }
    }
}
