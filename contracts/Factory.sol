// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.10;

import { Leverage } from "./Leverage.sol";

abstract contract Factory {
    event LeverageCreated(address indexed user, address leverage);

    function createLeverage() external virtual;
}
