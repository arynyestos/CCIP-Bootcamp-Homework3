# CCIP Bootcamp Day 3 Homework

On the third and final day of the course the [assignment](https://cll-devrel.gitbook.io/ccip-bootcamp/day-3/day-3-homework) was to measure the gas consumption of the ccipReceive function to then provide an accurate value to the `transferUsdc` call on the contract we used on [exercise 4](https://github.com/arynyestos/CCIP-Bootcamp-Exercise4). 

## Overview

Since for the aforementioned exercise the gas limit was 0, because we transferred the USDC to an EOA, this time we had to create a receiving contract. In this case we wrote a comprehensive Foundry test using CCIP Local Simulator in Forked Mode. In the [test](https://github.com/arynyestos/CCIP-Bootcamp-Homework3/blob/main/test/TransferAndSwap.t.sol) the following steps are followed:

1. Deploy TransferUSDC.sol to Avalanche Fuji.
2. Deploy CrossChainReceiver.sol and SwapTestnetUSDC.sol to Sepolia.
3. Call `TransferUSDC::allowlistDestination()` to make Sepolia an allowlisted chain.
4. Fund TransferUSDC.sol with 3 LINK to pay for CCIP fees.
5. Approve TransferUSDC to move 1 USDC from the signer's EOA.
6. Call `CrossChainReceiver::allowlistSourceChain()` to make Fuji an allowlisted source chain for CCIP transfers.
7. Call `TransferUSDC::transferUsdc()` to transfer 1 USDC from an EOA to the receiver contract.

## Results

With this test we could find out the amount of gas spent by the `TransferUSDC::transferUsdc()` function call, in order to adjust it so as not to waste resources....

TODO
