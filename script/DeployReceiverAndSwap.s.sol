// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SwapTestnetUSDC} from "../src/SwapTestnetUSDC.sol";
import {CrossChainReceiver} from "../src/CrossChainReceiver.sol";
import {SwapHelperConfig} from "./SwapHelperConfig.s.sol";
import {ReceiverHelperConfig} from "./ReceiverHelperConfig.s.sol";

contract DeployReceiverAndSwapScript is Script {
    SwapTestnetUSDC public swapTestnetUSDC;
    CrossChainReceiver public crossChainReceiver;

    function setUp() public {}

    function run() public returns (CrossChainReceiver, SwapTestnetUSDC) {
        ReceiverHelperConfig receiverHelperConfig = new ReceiverHelperConfig();
        (address router, address comet) = receiverHelperConfig.activeNetworkConfig();

        SwapHelperConfig swapHelperConfig = new SwapHelperConfig();
        (address usdc, address compoundUsdcToken, address fauceteer) = swapHelperConfig.activeNetworkConfig();

        vm.startBroadcast();

        swapTestnetUSDC = new SwapTestnetUSDC(usdc, compoundUsdcToken, fauceteer);
        crossChainReceiver = new CrossChainReceiver(router, comet, address(swapTestnetUSDC));

        vm.stopBroadcast();

        return (crossChainReceiver, swapTestnetUSDC);
    }
}
