export const getRpcURL = (network: string): string => {
    const apiKey = process.env.ALCHEMY_API_KEY
    if (!apiKey) throw new Error('ALCHEMY_API_KEY is not set')
    let baseURL = ''
    switch (network) {
        case 'sepolia': {
            baseURL = 'https://eth-sepolia.g.alchemy.com/v2/'
            break
        }
        case 'amoy': {
            baseURL = 'https://polygon-amoy.g.alchemy.com/v2/'
            break
        }
        case 'arbSepolia': {
            baseURL = 'https://arb-sepolia.g.alchemy.com/v2/'
            break
        }
        default: {
            throw new Error(`${network} Network RPC not configured`)
        }
    }
    return `${baseURL}${apiKey}`
}
