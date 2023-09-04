// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.10;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import { SwapAdapter } from "./abstracts/SwapAdapter.sol";
import { FlashloanAdapter } from "./abstracts/FlashloanAdapter.sol";
import { LendingAdapter } from "./abstracts/LendingAdapter.sol";
import "./library/utils.sol";

import "hardhat/console.sol";

abstract contract Leverage is Ownable, SwapAdapter, FlashloanAdapter, LendingAdapter {
    IERC20 immutable token;
    address immutable TOKEN;

    event Leveraged(uint256 ethAmount, uint256 paybackAmount);
    event Deleveraged(uint256 ethAmount, uint256 paybackAmount);

    receive() external payable {}

    constructor(address _token, address _user) {
        token = IERC20(_token);
        TOKEN = _token;

        transferOwnership(_user);
    }

    function leverage(uint256 loanAmount) external payable onlyOwner {
        // step 1. User deposit ETH to Leverage
        uint256 ethAmount = msg.value;

        // step 2. loan token from flashloanProvider
        _flashloan(TOKEN, loanAmount, abi.encode(true, ethAmount));
    }

    function deleverage() external onlyOwner {
        uint256 debtAmount = _debtAmount(TOKEN);

        // step 1. loan token from flashloanProvider
        _flashloan(TOKEN, debtAmount, abi.encode(false, 0));
    }

    function _flashloanCallback(address asset, uint256 amount, uint256 premium, bytes memory params) internal override {
        (bool direction, uint256 depositedEth) = abi.decode(params, (bool, uint256));
        uint256 paybackAmount = amount + premium;
        if (direction) {
            require(asset == TOKEN, "Flashloan callback asset doesn't match to token");
            // step 3. swap from token to eth on exchange
            (int256 amount0, ) = _swap(amount, 2);

            uint256 swappedEthAmount = uint256(-amount0);
            uint256 totalEth = swappedEthAmount + depositedEth;

            // step 4. deposit entire eth to lendingPool
            _deposit(ETH, totalEth);

            // step 5. borrow token from lendingPool
            _borrow(TOKEN, paybackAmount);

            // step 6. payback token to flashloanProvider
            _payback(TOKEN, paybackAmount);

            emit Leveraged(totalEth, paybackAmount);
        } else {
            // step 2. repay to lendingPool
            _repay(TOKEN, amount);

            uint256 totalEthAmount = _depositedAmount(ETH);

            // step 3. withdraw eth from lendingPool
            _withdraw(ETH, totalEthAmount);

            // step 4. swap eth to token on exchange
            (int256 amount0, int256 amount1) = _swap(paybackAmount, 1);
            require(uint256(-amount1) == paybackAmount, "Swap not completed");
            int256 remainEth = int256(totalEthAmount) - amount0;
            require(remainEth >= 0, "Eth amount is negative");

            console.log(address(this).balance, uint256(remainEth));
            // step 5. release Eth for user to withdraw
            (bool success, ) = payable(owner()).call{ value: uint256(remainEth) }("");
            require(success, "Eth sending failed");

            // step 6. payback token to flashloanProvider
            _payback(TOKEN, paybackAmount);

            emit Deleveraged(totalEthAmount, paybackAmount);
        }
    }
}
