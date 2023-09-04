// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.10;

import { IFlashLoanSimpleReceiver } from "@aave/core-v3/contracts/flashloan/interfaces/IFlashLoanSimpleReceiver.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IPool } from "../interfaces/IPool.sol";

contract MockAAVEPool is IPool {
    uint256 public constant FLASHLOAN_FEE_PERCENT = 100; // 100 means 1 %

    constructor() {}

    function supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external override {
        bool success = IERC20(asset).transferFrom(msg.sender, address(this), amount);
        require(success, "TransferFrom failed");
    }

    function withdraw(address asset, uint256 amount, address to) external override returns (uint256) {
        IERC20(asset).transfer(msg.sender, amount);
        return amount;
    }

    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external override {
        IERC20(asset).transfer(msg.sender, amount);
    }

    function repay(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        address onBehalfOf
    ) external override returns (uint256) {
        bool success = IERC20(asset).transferFrom(msg.sender, address(this), amount);
        require(success, "TransferFrom failed");
        return amount;
    }

    function flashLoanSimple(
        address receiverAddress,
        address asset,
        uint256 amount,
        bytes calldata params,
        uint16 referralCode
    ) external override {
        IERC20(asset).transfer(receiverAddress, amount);
        uint256 fee = (amount * FLASHLOAN_FEE_PERCENT) / 10000;

        require(
            IFlashLoanSimpleReceiver(receiverAddress).executeOperation(asset, amount, fee, address(this), params),
            "INVALID_FLASHLOAN_EXECUTOR_RETURN"
        );

        bool success = IERC20(asset).transferFrom(receiverAddress, address(this), amount + fee);
        require(success, "Payback is not completed");
    }
}
