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

    address public user1 = vm.addr(1231);
    address public owner = vm.addr(0xCFAE);
    Uniswap public uniswap;

    function setUp() public {
        vm.createSelectFork(vm.envString("MAINNET_RPC_URL"));
        vm.startPrank(owner);

        uniswap = new Uniswap();

        deal(DAI, user1, INITIAL_DAI_MINT_AMOUNT);
        deal(USDT, user1, INITIAL_USDT_MINT_AMOUNT);
        deal(WBTC, user1, INITIAL_WBTC_MINT_AMOUNT);

        vm.stopPrank();
    }

    function test_swap() public {
        vm.startPrank(user1);

        IERC20(DAI).safeIncreaseAllowance(address(uniswap), AMOUNT_IN);

        uint256 user1DAIBalanceBefore = IERC20(DAI).balanceOf(user1);
        uint256 user1WBTCBalanceBefore = IERC20(WBTC).balanceOf(user1);

        console2.log(StdStyle.magenta("================================================"));
        emit log_named_decimal_uint("DAI balance before", user1DAIBalanceBefore, ERC20(DAI).decimals());
        emit log_named_decimal_uint("WBTC balance before", user1WBTCBalanceBefore, ERC20(WBTC).decimals());

        uniswap.swap(
            DAI,
            WBTC,
            AMOUNT_IN,
            AMOUNT_OUT_MIN,
            user1,
            block.timestamp + 1
        );
        uint256 user1DAIBalanceAfter = IERC20(DAI).balanceOf(user1);
        uint256 user1WBTCBalanceAfter = IERC20(WBTC).balanceOf(user1);

        emit log_named_decimal_uint("DAI balance after", user1DAIBalanceAfter, ERC20(DAI).decimals());
        emit log_named_decimal_uint("WBTC balance after", user1WBTCBalanceAfter, ERC20(WBTC).decimals());
    }

    function test_addLiquidity() public {
        vm.startPrank(user1);

        address pair = IUniswapV2Factory(FACTORY).getPair(DAI, WBTC);

        (uint112 _reserve0Before, uint112 _reserve1Before,) = IUniswapV2Pair(pair).getReserves();

        emit log_named_decimal_uint("reserve WBTC", _reserve0Before, ERC20(WBTC).decimals());
        emit log_named_decimal_uint("reserve DAI", _reserve1Before, ERC20(DAI).decimals());

        IERC20(DAI).safeIncreaseAllowance(address(uniswap), type(uint256).max);
        IERC20(WBTC).safeIncreaseAllowance(address(uniswap), type(uint256).max);

        uint256 amountDAIToAdd = 50_000e18;
        uint256 amountWBTCToAdd = 2e8;

        (uint256 amountTokenA, uint256 amountTokenB, uint256 liquidity) = uniswap.addLiquidity(
            DAI,
            WBTC,
            amountDAIToAdd,
            amountWBTCToAdd,
            user1,
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

    function test_removeLiquidity() public {
        vm.startPrank(user1);

        address pair = IUniswapV2Factory(FACTORY).getPair(DAI, WBTC);
        
        console2.log(StdStyle.magenta("================ Before adding liquidity ================"));

        {
            (uint112 _reserve0Before, uint112 _reserve1Before,) = IUniswapV2Pair(pair).getReserves();
            emit log_named_decimal_uint("pool DAI balance", IERC20(DAI).balanceOf(pair), ERC20(DAI).decimals());
            emit log_named_decimal_uint("pool WBTC balance", IERC20(WBTC).balanceOf(pair), ERC20(WBTC).decimals());
            emit log_named_decimal_uint("pool DAI reserves", _reserve1Before, ERC20(DAI).decimals());
            emit log_named_decimal_uint("pool WBTC reserves", _reserve0Before, ERC20(WBTC).decimals());
        }

        IERC20(DAI).safeIncreaseAllowance(address(uniswap), type(uint256).max);
        IERC20(WBTC).safeIncreaseAllowance(address(uniswap), type(uint256).max);

        uint256 amountDAIToAdd = 50_000e18;
        uint256 amountWBTCToAdd = 2e8;

        (,, uint256 liquidity) = uniswap.addLiquidity(
            DAI,
            WBTC,
            amountDAIToAdd,
            amountWBTCToAdd,
            user1,
            block.timestamp + 1
        );

        emit log_named_decimal_uint("liquidity tokens minted", liquidity, IUniswapV2Pair(pair).decimals());

        console2.log(StdStyle.magenta("================ After adding liquidity ================"));

        {   
            (uint112 _reserve0Before, uint112 _reserve1Before,) = IUniswapV2Pair(pair).getReserves();
            emit log_named_decimal_uint("user1 LP tokens balance", IUniswapV2Pair(pair).balanceOf(user1), IUniswapV2Pair(pair).decimals());
            emit log_named_decimal_uint("pool DAI balance", IERC20(DAI).balanceOf(pair), ERC20(DAI).decimals());
            emit log_named_decimal_uint("pool WBTC balance", IERC20(WBTC).balanceOf(pair), ERC20(WBTC).decimals());
            emit log_named_decimal_uint("pool DAI reserves", _reserve1Before, ERC20(DAI).decimals());
            emit log_named_decimal_uint("pool WBTC reserves", _reserve0Before, ERC20(WBTC).decimals());
        }

        IERC20(pair).safeIncreaseAllowance(address(uniswap), type(uint256).max);

        uint256 liquidityToRemove = 1e15;
        (uint256 amountOfTokenARemoved, uint256 amountOfTokenBRemoved) = uniswap.removeLiquidity(
            DAI,
            WBTC,
            liquidityToRemove,
            1,
            1,
            user1,
            block.timestamp + 1
        );

        console2.log(StdStyle.magenta("================ After removing liquidity ================"));

        {   
            emit log_named_decimal_uint("amount of tokenA removed", amountOfTokenARemoved, ERC20(DAI).decimals());
            emit log_named_decimal_uint("amount of tokenB removed", amountOfTokenBRemoved, ERC20(WBTC).decimals());
            (uint112 _reserve0Before, uint112 _reserve1Before,) = IUniswapV2Pair(pair).getReserves();
            emit log_named_decimal_uint("user1 LP tokens balance", IUniswapV2Pair(pair).balanceOf(user1), IUniswapV2Pair(pair).decimals());
            emit log_named_decimal_uint("pool DAI balance", IERC20(DAI).balanceOf(pair), ERC20(DAI).decimals());
            emit log_named_decimal_uint("pool WBTC balance", IERC20(WBTC).balanceOf(pair), ERC20(WBTC).decimals());
            emit log_named_decimal_uint("pool DAI reserves", _reserve1Before, ERC20(DAI).decimals());
            emit log_named_decimal_uint("pool WBTC reserves", _reserve0Before, ERC20(WBTC).decimals());
        }
    }

    function test_skim() public {
        vm.startPrank(user1);

        address pair = IUniswapV2Factory(FACTORY).getPair(DAI, WBTC);
        
        console2.log(StdStyle.magenta("================ Before adding liquidity ================"));

        {
            (uint112 _reserve0Before, uint112 _reserve1Before,) = IUniswapV2Pair(pair).getReserves();
            emit log_named_decimal_uint("pool DAI balance", IERC20(DAI).balanceOf(pair), ERC20(DAI).decimals());
            emit log_named_decimal_uint("pool WBTC balance", IERC20(WBTC).balanceOf(pair), ERC20(WBTC).decimals());
            emit log_named_decimal_uint("pool DAI reserves", _reserve1Before, ERC20(DAI).decimals());
            emit log_named_decimal_uint("pool WBTC reserves", _reserve0Before, ERC20(WBTC).decimals());
        }

        IERC20(DAI).safeIncreaseAllowance(address(uniswap), type(uint256).max);
        IERC20(WBTC).safeIncreaseAllowance(address(uniswap), type(uint256).max);

        uint256 amountDAIToAdd = 50_000e18;
        uint256 amountWBTCToAdd = 2e8;

        (,, uint256 liquidity) = uniswap.addLiquidity(
            DAI,
            WBTC,
            amountDAIToAdd,
            amountWBTCToAdd,
            user1,
            block.timestamp + 1
        );

        emit log_named_decimal_uint("liquidity tokens minted", liquidity, IUniswapV2Pair(pair).decimals());

        console2.log(StdStyle.magenta("================ After adding liquidity and before direct transfer ================"));

        {   
            (uint112 _reserve0Before, uint112 _reserve1Before,) = IUniswapV2Pair(pair).getReserves();
            emit log_named_decimal_uint("user1 LP tokens balance", IUniswapV2Pair(pair).balanceOf(user1), IUniswapV2Pair(pair).decimals());
            emit log_named_decimal_uint("pool DAI balance", IERC20(DAI).balanceOf(pair), ERC20(DAI).decimals());
            emit log_named_decimal_uint("pool WBTC balance", IERC20(WBTC).balanceOf(pair), ERC20(WBTC).decimals());
            emit log_named_decimal_uint("pool DAI reserves", _reserve1Before, ERC20(DAI).decimals());
            emit log_named_decimal_uint("pool WBTC reserves", _reserve0Before, ERC20(WBTC).decimals());
        }

        {
            uint256 user1DAIBalanceBefore = IERC20(DAI).balanceOf(user1);
            emit log_named_decimal_uint("user1 DAI balance before direct transfer", user1DAIBalanceBefore, ERC20(DAI).decimals());
        }

        uint256 daiAmountToTransfer = 5_000e18;
        IERC20(DAI).safeTransfer(pair, daiAmountToTransfer);

        console2.log(StdStyle.magenta("================ After direct transfer ================"));

        {   
            uint256 user1DAIBalanceAfter = IERC20(DAI).balanceOf(user1);
            emit log_named_decimal_uint("user1 DAI balance before skim function used", user1DAIBalanceAfter, ERC20(DAI).decimals());
            (uint112 _reserve0Before, uint112 _reserve1Before,) = IUniswapV2Pair(pair).getReserves();
            emit log_named_decimal_uint("user1 LP tokens balance", IUniswapV2Pair(pair).balanceOf(user1), IUniswapV2Pair(pair).decimals());
            emit log_named_decimal_uint("pool DAI balance", IERC20(DAI).balanceOf(pair), ERC20(DAI).decimals());
            emit log_named_decimal_uint("pool WBTC balance", IERC20(WBTC).balanceOf(pair), ERC20(WBTC).decimals());
            emit log_named_decimal_uint("pool DAI reserves", _reserve1Before, ERC20(DAI).decimals());
            emit log_named_decimal_uint("pool WBTC reserves", _reserve0Before, ERC20(WBTC).decimals());
        }

        IUniswapV2Pair(pair).skim(user1);

        console2.log(StdStyle.magenta("================ After sync function used ================"));

        {   
            uint256 user1DAIBalanceAfter = IERC20(DAI).balanceOf(user1);
            emit log_named_decimal_uint("user1 DAI balance after skim function used", user1DAIBalanceAfter, ERC20(DAI).decimals());
            (uint112 _reserve0Before, uint112 _reserve1Before,) = IUniswapV2Pair(pair).getReserves();
            emit log_named_decimal_uint("user1 LP tokens balance", IUniswapV2Pair(pair).balanceOf(user1), IUniswapV2Pair(pair).decimals());
            emit log_named_decimal_uint("pool DAI balance", IERC20(DAI).balanceOf(pair), ERC20(DAI).decimals());
            emit log_named_decimal_uint("pool WBTC balance", IERC20(WBTC).balanceOf(pair), ERC20(WBTC).decimals());
            emit log_named_decimal_uint("pool DAI reserves", _reserve1Before, ERC20(DAI).decimals());
            emit log_named_decimal_uint("pool WBTC reserves", _reserve0Before, ERC20(WBTC).decimals());
        }
    }
}
