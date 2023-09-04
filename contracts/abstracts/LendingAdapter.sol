// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.10;

abstract contract LendingAdapter {
    event Deposited(address asset, uint256 amount);
    event Withdrawn(address asset, uint256 amount);
    event Borrowed(address asset, uint256 amount);
    event Repaid(address asset, uint256 amount);

    function _deposit(address asset, uint256 amount) internal virtual;

    function _withdraw(address asset, uint256 amount) internal virtual;

    function _borrow(address asset, uint256 amount) internal virtual;

    function _repay(address asset, uint256 amount) internal virtual;

    function _debtAmount(address asset) internal view virtual returns (uint256);

    function _depositedAmount(address asset) internal view virtual returns (uint256);
}
