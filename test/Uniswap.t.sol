// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/Test.sol";

import {Uniswap} from "../src/Uniswap.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract UniswapTest is Test {
    using SafeERC20 for IERC20;

    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant DAI_WHALE = 0x075e72a5eDf65F0A5f44699c7654C1a76941Ddc8;
    address private constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address private constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;


    address public USER_1 = vm.addr(111101);
    address public USER_2 = vm.addr(111102);

    uint256 private constant AMOUNT_IN = 10e2;
    uint256 private constant AMOUNT_OUT_MIN = 1;

    uint256 private constant INITIAL_WBTC_MINT_AMOUNT = 25;
    uint256 private constant INITIAL_DAI_MINT_AMOUNT = 1e5;

    address owner = vm.addr(0xCFAE);
    Uniswap uniswap;

    function setUp() public {
        vm.createSelectFork(vm.envString("MAINNET_RPC_URL"));
        vm.startPrank(owner);
        uniswap = new Uniswap();

        deal(DAI, USER_1, INITIAL_DAI_MINT_AMOUNT);
        deal(WBTC, USER_1, INITIAL_WBTC_MINT_AMOUNT);

        vm.stopPrank();
    }

    function testSwap() public {
        vm.startPrank(DAI_WHALE);
        IERC20(DAI).safeIncreaseAllowance(address(uniswap), AMOUNT_IN);
        uint256 daiBalanceBefore = IERC20(DAI).balanceOf(DAI_WHALE);
        uint256 WBTCBalanceBefore = IERC20(WBTC).balanceOf(DAI_WHALE);

        console2.log("DAI balance before:", daiBalanceBefore);
        console2.log("WBTC balance before:", WBTCBalanceBefore);

        uniswap.swap(
            DAI,
            WBTC,
            AMOUNT_IN,
            AMOUNT_OUT_MIN,
            DAI_WHALE,
            block.timestamp + 1
        );
        uint256 daiBalanceAfter = IERC20(DAI).balanceOf(DAI_WHALE);
        uint256 WBTCBalanceAfter = IERC20(WBTC).balanceOf(DAI_WHALE);

        console2.log("DAI balance after:", daiBalanceAfter);
        console2.log("WBTC balance after:", WBTCBalanceAfter);
    }

    function testUser1AddLiquidity() public {
        vm.startPrank(USER_1);

        uint256 amountDAIToAdd = 1e5;
        uint256 amountWBTCToAdd = 1;

        IERC20(DAI).safeIncreaseAllowance(address(uniswap), amountDAIToAdd);
        IERC20(WBTC).safeIncreaseAllowance(address(uniswap), amountWBTCToAdd);
        (uint256 amountTokenA, uint256 amountTokenB, uint256 liquidity) = uniswap.addLiquidity(
            DAI,
            WBTC,
            amountDAIToAdd,
            amountWBTCToAdd,
            USER_1,
            block.timestamp + 1
        );

        console2.log("added tokenA amount: ", amountTokenA);
        console2.log("added tokenB amount: ", amountTokenB);
        console2.log("received liquidity tokens amount: ", liquidity);
    }
}
