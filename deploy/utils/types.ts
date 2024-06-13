import type { BigNumberish } from 'ethers'

export type Address = `0x${string}`

export type BridgeableTokenConfig = {
    lzName: string
    lzSymbol: string
    principalTokenSymbol: string
    principalTokenAddress: Address
    delegate: Address
    feesRecipient: Address
    mintDailyLimit: BigNumberish
    globalMintLimit: BigNumberish
    burnDailyLimit: BigNumberish
    globalBurnLimit: BigNumberish
    feesRate: number
    isIsolateMode: boolean
}
