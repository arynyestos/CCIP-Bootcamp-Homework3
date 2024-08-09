# CCIP Bootcamp Day 3 Homework

### Disclaimer

This README explains the steps I took and the reason I didn't fully achieve my goal for this last assignment. Due to the fact that I believe to have proved my compromise to the course and to have learned more than enough to be awarded the certificate of completion, along with the fact that **I got married the week after the bootcamp**, this was left unfinished. Nonetheless, I intend to find what the issue was after the summer, hopefully before the RWA bootcamp. Also, please bear in mind that I attempted to complete the exercise in a more complex way than expected when evaluating my work for this exercise.

---

On the third and final day of the course the [assignment](https://cll-devrel.gitbook.io/ccip-bootcamp/day-3/day-3-homework) was to measure the gas consumption of the `_ccipReceive()` function to then provide an accurate value to the `transferUsdc()` call on the contract we used on [exercise 4](https://github.com/arynyestos/CCIP-Bootcamp-Exercise4). 

Since for the aforementioned exercise the gas limit was 0, because we transferred the USDC to an EOA, this time we had to create a receiving contract. The resources linked in the assignment's description were a Chainlink Docs [entry](https://docs.chain.link/ccip/tutorials/ccipreceive-gaslimit) on how to estimate gas, and a [Gitbook](https://cll-devrel.gitbook.io/ccip-masterclass-4/ccip-masterclass/exercise-2-deposit-transferred-usdc-to-compound-v3) on how to deposit transferred USDC on Compound V3, following up on an exercise exactly like exercise 4. Looking at these, it seemed like following the whole Gitbook through in a test using CCIP Local Simulator in Forked Mode would be a great way to round up everything learnt throughout the course. Once the test were correctly configured, we would just have to take the `gasUsed` parameter of the `MockCCIPRouter::MsgExecuted` event, increase it by 10% and use that as the `gasLimit` parameter of the `TransferUSDC::transferUsdc()` function.

## Overview
To do this, we wrote a comprehensive Foundry test you can see [here](https://github.com/arynyestos/CCIP-Bootcamp-Homework3/blob/main/test/TransferAndSwap.t.sol), in which the following steps are followed (bear in mind that all of this happens locally, leveraging Forked CCIP Local Simulator):

1. Deploy TransferUSDC.sol to Avalanche Fuji.
2. Deploy CrossChainReceiver.sol and SwapTestnetUSDC.sol to Sepolia.
3. Call `TransferUSDC::allowlistDestination()` to make Sepolia an allowlisted chain.
4. Fund TransferUSDC.sol with 3 LINK to pay for CCIP fees.
5. Approve TransferUSDC to move 1 USDC from the signer's EOA.
6. Call `CrossChainReceiver::allowlistSourceChain()` to make Fuji an allowlisted source chain for CCIP transfers.
7. Call `TransferUSDC::transferUsdc()` to transfer 1 USDC from an EOA to the receiver contract.
8. Call `CCIPLocalSimulatorFork::switchChainAndRouteMessage()` to route the CCIP message.

Following these steps, the `MockCCIPRouter::MsgExecuted`, which looks as follows,

```JavaScript
event MsgExecuted(bool success, bytes retData, uint256 gasUsed);
```

should be emitted, giving us the gasUsed value we were looking for to get an estimation of the gas consumption of the `_ccipReceive()` in this use case.

## Results

However, the outcome wasn't as expected. The transaction went so far as to call `EVM2EVMOffRamp::executeSingleMessage()` on [Sepolia](https://sepolia.etherscan.io/address/0x000b26f604eAadC3D874a4404bde6D64a97d95ca#code), after burning the USDC token, by calling `USDCTokenPool::lockOrBurn` on [Fuji](https://testnet.snowtrace.io/address/0x4ED8867f9947A5fe140C9dC1c6f207F3489F501E/contract/43113/code) but an unhandled revert happened upon calling `IPool::releaseOrMint()` (cannot be sure which contract exactly it is, because it is not verified on [Sepolia Etherscan](https://sepolia.etherscan.io/address/0x3fF675B880aC9F67AC6f4342FfD9e99B80469bAd)) was thrown, as shown in the screenshot below:

![image](https://github.com/user-attachments/assets/e01966c7-c45f-4720-acf1-6dddb6e02c63)

Even the `RateLimiter::TokenConsumed` event got emitted for 1 USDC, but since the transaction didn't go through, the `MockCCIPRouter::MsgExecuted` didn't get emitted, so we couldn't get the gas estimation we were looking for ☹
