// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";

contract ReceiverHelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address router;
        address comet;
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
            router: 0xF694E193200268f9a4868e4Aa017A0118C9a8177,
            comet: 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846
        });
    }

    function _getSepoliaConfig() internal pure returns (NetworkConfig memory SepoliaConfig) {
        SepoliaConfig = NetworkConfig({
            router: 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59,
            comet: 0xAec1F48e02Cfb822Be958B68C7957156EB3F0b6e
        });
    }
}
