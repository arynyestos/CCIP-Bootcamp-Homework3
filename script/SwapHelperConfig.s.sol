// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";

contract SwapHelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address usdc;
        address compoundUsdcToken;
        address fauceteer;
    }

    constructor() {
        if (block.chainid == 43113) {
            activeNetworkConfig = _getFujiConfig();
        } else if (block.chainid == 11155111) {
            activeNetworkConfig = _getSepoliaConfig();
        }
    }

    // @notice these addresses are wrong, but we won't be deplyoing on Fuji for this example
    function _getFujiConfig() internal pure returns (NetworkConfig memory FujiConfig) {
        FujiConfig = NetworkConfig({
            usdc: 0xF694E193200268f9a4868e4Aa017A0118C9a8177,
            compoundUsdcToken: 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846,
            fauceteer: 0x5425890298aed601595a70AB815c96711a31Bc65
        });
    }

    function _getSepoliaConfig() internal pure returns (NetworkConfig memory SepoliaConfig) {
        SepoliaConfig = NetworkConfig({
            usdc: 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238,
            compoundUsdcToken: 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238,
            fauceteer: 0x68793eA49297eB75DFB4610B68e076D2A5c7646C
        });
    }
}
