import type { CallOptions } from 'hardhat-deploy/types'

export const GAS: CallOptions = {
    maxFeePerGas: '20000000000', // 20 gwei
    maxPriorityFeePerGas: '1000000000',
}
