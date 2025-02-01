import type { BigNumberish } from 'ethers'

export type Address = `0x${string}`

export type BridgeableTokenConfig = {
    lzName: string
    lzSymbol: string
    principalTokenSymbol: string
    principalTokenAddress: Address
    delegate: Address
    feesRecipient: Address
    dailyCreditLimit: BigNumberish
    globalCreditLimit: BigNumberish
    dailyDebitLimit: BigNumberish
    globalDebitLimit: BigNumberish
    initialPrincipalTokenAmountMinted: BigNumberish
    initialCreditDebitBalance: BigNumberish
    feesRate: number
    isIsolateMode: boolean
}
