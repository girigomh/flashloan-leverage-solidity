// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.10;

abstract contract SwapAdapter {
    event Swapped(uint256 amount, uint16 mode, int256 amount0, int256 amount1);

    /*
        mode 0: from eth to token with eth amount
        mode 1: from eth to token with token amount
        mode 2: from token to eth with token amount
        mode 3: from token to eth with eth amount
    */
    function _swap(uint256 amount, uint16 mode) internal virtual returns (int256 amount0, int256 amount1);
}
