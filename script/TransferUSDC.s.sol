// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {TransferUSDC} from "../src/TransferUSDC.sol";
import {TransferHelperConfig} from "./TransferHelperConfig.s.sol";

contract TransferUSDCScript is Script {
    TransferUSDC public transferUSDC;

    function setUp() public {}

    function run() public returns (TransferUSDC) {
        TransferHelperConfig transferHelperConfig = new TransferHelperConfig();
        (address router, address link, address usdc) = transferHelperConfig.activeNetworkConfig();

        vm.startBroadcast();

        transferUSDC = new TransferUSDC(router, link, usdc);

        vm.stopBroadcast();

        return transferUSDC;
    }
}
