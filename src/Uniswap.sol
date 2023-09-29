// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IUniswapV2Router02} from "@uniswap-v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Factory} from "@uniswap-v2-core/contracts/interfaces/IUniswapV2Factory.sol";
contract Uniswap {
    using SafeERC20 for IERC20;

    address private constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    /**
     * @param _tokenIn address of the token we want to swap.
     * @param _tokenOut address of the token we want to receive.
     * @param _amountIn amount of token that we trading in.
     * @param _amountOutMin minimum amount of tokens that we want out of this trade.
     * @param _to address to send output tokens to.
     * @param _deadline timestamp before Tx is still valid.
     */
    function swap(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to,
        uint256 _deadline
    ) external {
        IERC20(_tokenIn).safeTransferFrom(msg.sender, address(this), _amountIn);
        IERC20(_tokenIn).safeIncreaseAllowance(UNISWAP_V2_ROUTER, _amountIn);

        address[] memory path = new address[](3);
        path[0] = _tokenIn;
        path[1] = WETH;
        path[2] = _tokenOut;

        IUniswapV2Router02(UNISWAP_V2_ROUTER).swapExactTokensForTokens(
            _amountIn, 
            _amountOutMin,
            path,
            _to,
            _deadline
        );
    }

    /**
     * @param _tokenA address of the first token that should be deposited into the pair exchange.
     * @param _tokenB address of the second token that should be deposited into the pair exchange.
     * @param _amountTokenA maximum amount of tokenA to be deposited.
     * @param _amountTokenB maximum amount of tokenB to be deposited.
     * @param _to address to send output tokens to
     * @param _deadline timestamp before Tx is still valid.
     */
    function addLiquidity(
        address _tokenA,
        address _tokenB,
        uint256 _amountTokenA,
        uint256 _amountTokenB,
        address _to,
        uint256 _deadline
    ) external returns (uint256, uint256, uint256) {
        IERC20(_tokenA).safeTransferFrom(msg.sender, address(this), _amountTokenA);
        IERC20(_tokenB).safeTransferFrom(msg.sender, address(this), _amountTokenB);

        IERC20(_tokenA).safeIncreaseAllowance(UNISWAP_V2_ROUTER, _amountTokenA);
        IERC20(_tokenB).safeIncreaseAllowance(UNISWAP_V2_ROUTER, _amountTokenB);

        (uint256 amountTokenA, uint256 amountTokenB, uint256 liquidity) = 
            IUniswapV2Router02(UNISWAP_V2_ROUTER).addLiquidity(
            _tokenA,
            _tokenB,
            _amountTokenA,
            _amountTokenB,
            1,
            1,
            _to,
            _deadline
        );

        return (amountTokenA, amountTokenB, liquidity);
    }

    /**
     * @param _tokenA address of the first token that should be deposited into the pair exchange.
     * @param _tokenB address of the second token that should be deposited into the pair exchange.
     * @param _liquidity amount of liquidity tokens to burn.
     * @param _amountTokenA amount of tokenA to be received by user.
     * @param _amountTokenB amount of tokenB to be received by user.
     * @param _to address to send output tokens to.
     * @param _deadline timestamp before Tx is still valid.
     */
    function removeLiquidity(
        address _tokenA,
        address _tokenB,
        uint256 _liquidity,
        uint256 _amountTokenA,
        uint256 _amountTokenB,
        address _to,
        uint256 _deadline
    ) external returns (uint256, uint256) {
        address pair = IUniswapV2Factory(FACTORY).getPair(_tokenA, _tokenB);
        IERC20(pair).safeTransferFrom(msg.sender, address(this), _liquidity);
        IERC20(pair).safeIncreaseAllowance(UNISWAP_V2_ROUTER, _liquidity);
        (uint256 amountTokenA, uint256 amountTokenB) = IUniswapV2Router02(UNISWAP_V2_ROUTER).removeLiquidity(
            _tokenA,
            _tokenB,
            _liquidity,
            _amountTokenA,
            _amountTokenB,
            _to,
            _deadline
        );

        return (amountTokenA, amountTokenB);
    }
}
