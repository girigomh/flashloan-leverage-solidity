// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.10;

abstract contract FlashloanAdapter {
    event Flashloaned(address token, uint256 amount);
    event Paidback(address token, uint256 amount);

    function _flashloan(address token, uint256 amount, bytes memory params) internal virtual;

    function _flashloanCallback(address asset, uint256 amount, uint256 premium, bytes memory params) internal virtual;

    function _payback(address token, uint256 amount) internal virtual;
}
