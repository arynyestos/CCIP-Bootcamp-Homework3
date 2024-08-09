// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {CCIPLocalSimulatorFork, Register} from "@chainlink/local/src/ccip/CCIPLocalSimulatorFork.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {TransferUSDC} from "../src/TransferUSDC.sol";
import {CrossChainReceiver} from "../src/CrossChainReceiver.sol";
import {SwapTestnetUSDC} from "../src/SwapTestnetUSDC.sol";
import {TransferUSDCScript} from "../script/TransferUSDC.s.sol";
import {DeployReceiverAndSwapScript} from "../script/DeployReceiverAndSwap.s.sol";
import {EncodeExtraArgs} from "./utils/EncodeExtraArgs.sol";
import {TransferHelperConfig} from "../script/TransferHelperConfig.s.sol";
import {SwapHelperConfig} from "../script/SwapHelperConfig.s.sol";
import {ReceiverHelperConfig} from "../script/ReceiverHelperConfig.s.sol";

contract CrossChainTransferUsdcTest is Test {
    CCIPLocalSimulatorFork public ccipLocalSimulatorFork;
    uint256 sepoliaFork;
    uint256 fujiFork;
    Register.NetworkDetails sepoliaNetworkDetails;
    Register.NetworkDetails fujiNetworkDetails;

    TransferUSDC public fujiTransfer;
    TransferUSDCScript public deployTransferUSDC;
    CrossChainReceiver public sepoliaReceiver;
    SwapTestnetUSDC public sepoliaSwap;
    DeployReceiverAndSwapScript public deployReceiverAndSwap;

    address fujiRouter;
    address fujiLink;
    address fujiUsdc;
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address USER = vm.addr(deployerPrivateKey);
    address sepoliaUsdc; // = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;

    function setUp() public {
        string memory SEPOLIA_RPC_URL = vm.envString("SEPOLIA_RPC_URL");
        string memory FUJI_RPC_URL = vm.envString("FUJI_RPC_URL");
        sepoliaFork = vm.createFork(SEPOLIA_RPC_URL);
        fujiFork = vm.createSelectFork(FUJI_RPC_URL);

        ccipLocalSimulatorFork = new CCIPLocalSimulatorFork();
        vm.makePersistent(address(ccipLocalSimulatorFork));

        // Step 1) Deploy TransferUSDC.sol to Avalanche Fuji
        assertEq(vm.activeFork(), fujiFork);

        fujiNetworkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid); // we are currently on Avalanche Fuji Fork
        assertEq(
            fujiNetworkDetails.chainSelector,
            14767482510784806043,
            "Sanity check: Ethereum Sepolia chain selector should be 14767482510784806043"
        );

        TransferHelperConfig transferHelperConfig = new TransferHelperConfig();
        (fujiRouter, fujiLink, fujiUsdc) = transferHelperConfig.activeNetworkConfig();

        vm.prank(USER);
        fujiTransfer = new TransferUSDC(fujiRouter, fujiLink, fujiUsdc);

        // Step 2) Deploy CrossChainReceiver.sol and SwapTestnetUSDC.sol to Sepolia
        vm.selectFork(sepoliaFork);
        assertEq(vm.activeFork(), sepoliaFork);

        sepoliaNetworkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid); // we are currently on Sepolia Fork
        assertEq(
            sepoliaNetworkDetails.chainSelector,
            16015286601757825753,
            "Sanity check: Arbitrum Sepolia chain selector should be 16015286601757825753"
        );

        ReceiverHelperConfig receiverHelperConfig = new ReceiverHelperConfig();
        (address router, address comet) = receiverHelperConfig.activeNetworkConfig();

        SwapHelperConfig swapHelperConfig = new SwapHelperConfig();
        address compoundUsdcToken;
        address fauceteer;
        (sepoliaUsdc, compoundUsdcToken, fauceteer) = swapHelperConfig.activeNetworkConfig();

        vm.startPrank(USER);
        sepoliaSwap = new SwapTestnetUSDC(sepoliaUsdc, compoundUsdcToken, fauceteer);
        sepoliaReceiver = new CrossChainReceiver(router, comet, address(sepoliaSwap));
        vm.stopPrank();

        // deployReceiverAndSwap = new DeployReceiverAndSwapScript();
        // vm.allowCheatcodes(address(deployReceiverAndSwap));
        // (sepoliaReceiver, sepoliaSwap) = deployReceiverAndSwap.run();

        // Step 3) On Fuji call TransferUSDC::allowlistDestination()
        vm.selectFork(fujiFork);
        assertEq(vm.activeFork(), fujiFork);
        vm.prank(USER);
        fujiTransfer.allowlistDestinationChain(sepoliaNetworkDetails.chainSelector, true);

        // Step 4) On Fuji, fund TransferUSDC.sol with 3 LINK
        ccipLocalSimulatorFork.requestLinkFromFaucet(address(fujiTransfer), 3 ether);

        // Step 5) Approve TransferUSDC to move 1 USDC
        vm.prank(USER);
        IERC20(fujiUsdc).approve(address(fujiTransfer), 1_000_000); // USDC has six decimals
        uint256 allowance = IERC20(fujiUsdc).allowance(USER, address(fujiTransfer));
        console.log("User allowance for USDC transfer contract:", allowance);

        // Step 6) Call CrossChainReceiver::allowlistSourceChain()
        vm.selectFork(sepoliaFork);
        assertEq(vm.activeFork(), sepoliaFork);
        vm.prank(USER);
        sepoliaReceiver.allowlistSourceChain(fujiNetworkDetails.chainSelector, true);
    }

    function testTransferUSDC() public {
        // Step 7) Call TransferUSDC::transferUsdc()
        vm.selectFork(fujiFork);
        assertEq(vm.activeFork(), fujiFork);
        vm.prank(USER);
        fujiTransfer.transferUsdc(sepoliaNetworkDetails.chainSelector, address(sepoliaReceiver), 1_000_000, 0);

        // vm.selectFork(sepoliaFork);
        // assertEq(vm.activeFork(), sepoliaFork);

        ccipLocalSimulatorFork.switchChainAndRouteMessage(sepoliaFork);
        assertEq(IERC20(sepoliaUsdc).balanceOf(address(sepoliaReceiver)), 1_000_000);
    }
}
