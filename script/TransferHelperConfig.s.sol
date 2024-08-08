// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";

contract TransferHelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address router;
        address link;
        address usdc;
    }

    constructor() {
        if (block.chainid == 43113) {
            activeNetworkConfig = _getFujiConfig();
        } else if (block.chainid == 11155111) {
            activeNetworkConfig = _getSepoliaConfig();
        }
    }

    function _getFujiConfig() internal pure returns (NetworkConfig memory FujiConfig) {
        FujiConfig = NetworkConfig({
            router: 0xF694E193200268f9a4868e4Aa017A0118C9a8177,
            link: 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846,
            usdc: 0x5425890298aed601595a70AB815c96711a31Bc65
        });
    }

    function _getSepoliaConfig() internal pure returns (NetworkConfig memory SepoliaConfig) {
        SepoliaConfig = NetworkConfig({
            router: 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59,
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            usdc: 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238
        });
    }
}
