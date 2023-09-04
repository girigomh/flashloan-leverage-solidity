// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.10;

import { Leverage } from "../Leverage.sol";
import { AaveFlashloan } from "../adapters/AaveFlashloan.sol";
import { AaveLending } from "../adapters/AaveLending.sol";
import { UniswapSwap } from "../adapters/UniswapSwap.sol";

import "hardhat/console.sol";

contract SimpleLeverage is Leverage, AaveFlashloan, AaveLending, UniswapSwap {
    constructor(
        address _token,
        address _user,
        address _aaveProvider,
        address _uniswapV3Pool,
        address _aaveWETH
    )
        Leverage(_token, _user)
        AaveFlashloan(_aaveProvider)
        AaveLending(_aaveProvider, _aaveWETH)
        UniswapSwap(_uniswapV3Pool)
    {}
}
