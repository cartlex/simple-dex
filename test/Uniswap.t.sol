// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {IUniswapV2Factory} from "@uniswap-v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "@uniswap-v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Router02} from "@uniswap-v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

import {Test, console2, StdStyle} from "forge-std/Test.sol";
import {Uniswap} from "../src/Uniswap.sol";
import {Constants} from "./Constants.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract UniswapTest is Test, Constants {
    using SafeERC20 for IERC20;

    address public USER_1 = vm.addr(1231);
    address public OWNER = vm.addr(0xCFAE);

    Uniswap public uniswap;

    function setUp() public {
        vm.createSelectFork(vm.envString("MAINNET_RPC_URL"));
        vm.startPrank(OWNER);

        uniswap = new Uniswap();

        deal(DAI, USER_1, INITIAL_DAI_MINT_AMOUNT);
        deal(USDT, USER_1, INITIAL_USDT_MINT_AMOUNT);
        deal(WBTC, USER_1, INITIAL_WBTC_MINT_AMOUNT);

        vm.stopPrank();
    }

    // function testSwap() public {
    //     vm.startPrank(DAI_WHALE);
    //     IERC20(DAI).safeIncreaseAllowance(address(uniswap), AMOUNT_IN);
    //     IERC20(WBTC).safeIncreaseAllowance(address(uniswap), AMOUNT_IN);
    //     uint256 daiBalanceBefore = IERC20(DAI).balanceOf(DAI_WHALE);
    //     uint256 WBTCBalanceBefore = IERC20(WBTC).balanceOf(DAI_WHALE);

    //     console2.log("DAI balance before:", daiBalanceBefore);
    //     console2.log("WBTC balance before:", WBTCBalanceBefore);

    //     uniswap.swap(
    //         DAI,
    //         WBTC,
    //         AMOUNT_IN,
    //         AMOUNT_OUT_MIN,
    //         DAI_WHALE,
    //         block.timestamp + 1
    //     );
    //     uint256 daiBalanceAfter = IERC20(DAI).balanceOf(DAI_WHALE);
    //     uint256 WBTCBalanceAfter = IERC20(WBTC).balanceOf(DAI_WHALE);

    //     console2.log("DAI balance after:", daiBalanceAfter);
    //     console2.log("WBTC balance after:", WBTCBalanceAfter);
    // }

    function testUser1AddLiquidity() public {
        vm.startPrank(USER_1);

        address pair = IUniswapV2Factory(FACTORY).getPair(DAI, WBTC);

        (uint112 _reserve0Before, uint112 _reserve1Before,) = IUniswapV2Pair(pair).getReserves();

        emit log_named_decimal_uint("reserve WBTC", _reserve0Before, ERC20(WBTC).decimals());
        emit log_named_decimal_uint("reserve DAI", _reserve1Before, ERC20(DAI).decimals());

        uint256 amountDAIToAdd = 50_000e18;
        uint256 amountWBTCToAdd = 2e8;

        IERC20(DAI).safeIncreaseAllowance(address(uniswap), type(uint256).max);
        IERC20(WBTC).safeIncreaseAllowance(address(uniswap), type(uint256).max);

        (uint256 amountTokenA, uint256 amountTokenB, uint256 liquidity) = uniswap.addLiquidity(
            DAI,
            WBTC,
            amountDAIToAdd,
            amountWBTCToAdd,
            USER_1,
            block.timestamp + 1
        );

        console2.log(StdStyle.magenta("================================================"));
        emit log_named_decimal_uint("Amount tokenA added", amountTokenA, ERC20(DAI).decimals());
        emit log_named_decimal_uint("Amount tokenB added", amountTokenB, ERC20(WBTC).decimals());
        emit log_named_decimal_uint("Liquidity tokens minted", liquidity, IUniswapV2Pair(pair).decimals());

        (uint112 _reserve0After, uint112 _reserve1After,) = IUniswapV2Pair(pair).getReserves();

        emit log_named_decimal_uint("reserve WBTC", _reserve0After, ERC20(WBTC).decimals());
        emit log_named_decimal_uint("reserve DAI", _reserve1After, ERC20(DAI).decimals());
    }
}
