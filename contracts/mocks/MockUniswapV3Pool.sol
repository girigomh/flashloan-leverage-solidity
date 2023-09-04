// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.10;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IUniswapV3Pool } from "../interfaces/IUniswapV3Pool.sol";

import "hardhat/console.sol";

contract MockUniswapV3Pool is IUniswapV3Pool {
    address public immutable token0;
    address public immutable token1;

    constructor(address _token0, address _token1) {
        token0 = _token0;
        token1 = _token1;
    }

    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1) {
        require(amountSpecified != 0, "Zero amount");
        int256 totAmount0 = int256(IERC20(token0).balanceOf(address(this)));
        int256 totAmount1 = int256(IERC20(token1).balanceOf(address(this)));
        bool posAmount = amountSpecified > 0;
        require(totAmount0 > 0 && totAmount1 > 0, "Zero fund in pool");
        if (zeroForOne == posAmount) {
            amount0 = amountSpecified;
            require(totAmount0 + amount0 > 0, "Negative amount after swap");
            amount1 = (-amount0 * totAmount1) / (totAmount0 + amount0);
        } else {
            amount1 = amountSpecified;
            require(totAmount1 + amount1 > 0, "Negative amount after swap");
            amount0 = (-totAmount0 * amount1) / (totAmount1 + amount1);
        }
        if (zeroForOne) {
            bool success = IERC20(token0).transferFrom(recipient, address(this), uint256(amount0));
            require(success, "Infund failed");
            IERC20(token1).transfer(recipient, uint256(-amount1));
        } else {
            bool success = IERC20(token1).transferFrom(recipient, address(this), uint256(amount1));
            require(success, "Infund failed");
            IERC20(token0).transfer(recipient, uint256(-amount0));
        }
    }
}
