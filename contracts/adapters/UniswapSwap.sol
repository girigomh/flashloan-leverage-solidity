// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.10;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IUniswapV3Pool } from "../interfaces/IUniswapV3Pool.sol";
import { IWETH } from "../interfaces/IWETH.sol";
import { SwapAdapter } from "../abstracts/SwapAdapter.sol";

import "hardhat/console.sol";

/*
    token0 is WETH
    token1 is token
*/
contract UniswapSwap is SwapAdapter {
    IUniswapV3Pool immutable uniswapV3Pool;
    IWETH private immutable weth;
    IERC20 private immutable token;

    constructor(address _uniswapV3Pool) {
        uniswapV3Pool = IUniswapV3Pool(_uniswapV3Pool);
        weth = IWETH(uniswapV3Pool.token0());
        token = IERC20(uniswapV3Pool.token1());
    }

    /*
        mode 0: from eth to token with eth amount
        mode 1: from eth to token with token amount
        mode 2: from token to eth with token amount
        mode 3: from token to eth with eth amount
    */
    function _swap(uint256 amount, uint16 mode) internal override returns (int256 amount0, int256 amount1) {
        require(mode >= 0 && mode < 4, "Unknown mode");
        int256 amountSpecified = (mode & 1 == 0) ? int256(amount) : -int256(amount);
        bool zeroForOne = mode & 2 == 0;

        uint256 orgBalance = address(this).balance;

        if (mode == 0) {
            weth.deposit{ value: amount }();
            weth.approve(address(uniswapV3Pool), amount);
        } else if (mode == 1) {
            weth.deposit{ value: orgBalance }();
            weth.approve(address(uniswapV3Pool), orgBalance);
        } else if (mode == 2) {
            token.approve(address(uniswapV3Pool), amount);
        } else {
            token.approve(address(uniswapV3Pool), token.balanceOf(address(this)));
        }

        (amount0, amount1) = uniswapV3Pool.swap(address(this), zeroForOne, amountSpecified, 0, "");
        if (mode == 1) {
            require(uint256(amount0) <= orgBalance, "Exceed than orgbalance");
            weth.withdraw(orgBalance - uint256(amount0));
        }
        if (mode == 3) {
            token.approve(address(uniswapV3Pool), 0);
        }
        if (mode & 2 == 2) {
            weth.withdraw(uint256(-amount0));
        }
        emit Swapped(amount, mode, amount0, amount1);
    }
}
