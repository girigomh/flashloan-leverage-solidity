// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.10;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import { IPool } from "../interfaces/IPool.sol";
import { IWETH } from "../interfaces/IWETH.sol";
import { LendingAdapter } from "../abstracts/LendingAdapter.sol";
import "../library/utils.sol";

import "hardhat/console.sol";

contract AaveLending is LendingAdapter {
    mapping(address => uint256) private depositedAssets;
    mapping(address => uint256) private borrowedAssets;

    IPool private immutable POOL;
    IWETH private immutable weth;

    constructor(address _aaveProvider, address _weth) {
        POOL = IPool(IPoolAddressesProvider(_aaveProvider).getPool());
        weth = IWETH(_weth);
    }

    function _deposit(address _asset, uint256 amount) internal override {
        address asset = _asset;
        if (_asset == ETH) {
            weth.deposit{ value: amount }();
            asset = address(weth);
        }
        IERC20(asset).approve(address(POOL), amount);
        POOL.supply(asset, amount, address(this), 0);
        depositedAssets[_asset] += amount;
        emit Deposited(_asset, amount);
    }

    function _withdraw(address _asset, uint256 amount) internal override {
        address asset = _asset;
        if (_asset == ETH) {
            asset = address(weth);
        }
        POOL.withdraw(asset, amount, address(this));
        if (_asset == ETH) {
            weth.withdraw(amount);
        }
        depositedAssets[_asset] -= amount;
        emit Withdrawn(_asset, amount);
    }

    function _borrow(address _asset, uint256 amount) internal override {
        address asset = _asset;
        if (_asset == ETH) {
            asset = address(weth);
        }
        POOL.borrow(asset, amount, 1, 0, address(this));
        if (_asset == ETH) {
            weth.withdraw(amount);
        }
        borrowedAssets[_asset] += amount;
        emit Borrowed(_asset, amount);
    }

    function _repay(address _asset, uint256 amount) internal override {
        address asset = _asset;
        if (_asset == ETH) {
            weth.deposit{ value: amount }();
            asset = address(weth);
        }
        IERC20(asset).approve(address(POOL), amount);
        POOL.repay(asset, amount, 1, address(this));
        borrowedAssets[_asset] -= amount;
        emit Repaid(_asset, amount);
    }

    function _debtAmount(address asset) internal view override returns (uint256) {
        return borrowedAssets[asset];
    }

    function _depositedAmount(address asset) internal view override returns (uint256) {
        return depositedAssets[asset];
    }
}
