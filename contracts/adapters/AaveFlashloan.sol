// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.10;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import { FlashloanAdapter } from "../abstracts/FlashloanAdapter.sol";
import "../library/utils.sol";

abstract contract AaveFlashloan is FlashloanAdapter, FlashLoanSimpleReceiverBase {
    constructor(address _aaveProvider) FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_aaveProvider)) {}

    function _flashloan(address token, uint256 amount, bytes memory params) internal override {
        require(token != ETH, "Native token is not allowed to flashloan");
        POOL.flashLoanSimple(address(this), token, amount, params, 0);
        emit Flashloaned(token, amount);
    }

    function _payback(address token, uint256 amount) internal override {
        require(token != ETH, "Native token is not allowed to flashloan payback");
        IERC20(token).approve(address(POOL), amount);
        emit Paidback(token, amount);
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address, // initiator
        bytes memory params
    ) public override returns (bool) {
        _flashloanCallback(asset, amount, premium, params);
        return true;
    }
}
