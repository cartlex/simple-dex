// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;


contract Constants {
    address internal constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address internal constant DAI_WHALE = 0x075e72a5eDf65F0A5f44699c7654C1a76941Ddc8;
    address internal constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address internal constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    address internal constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address internal constant FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

    uint256 internal constant AMOUNT_IN = 30_000e18;
    uint256 internal constant AMOUNT_OUT_MIN = 1e8;

    uint256 internal constant INITIAL_WBTC_MINT_AMOUNT = 50e8;
    uint256 internal constant INITIAL_DAI_MINT_AMOUNT = 1_000_000e18;
    uint256 internal constant INITIAL_USDT_MINT_AMOUNT = 1_000_000e6;

}