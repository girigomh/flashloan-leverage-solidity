// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.10;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    uint8 dec;

    /**
     * @notice This contract is for mintable ERC20 token
     * @param name token name of the MockToken
     * @param symbol token symbol of the MockToken
     * @param _dec number of decimals of the MockToken
     */
    constructor(string memory name, string memory symbol, uint8 _dec) ERC20(name, symbol) {
        dec = _dec;
    }

    function mintTo(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function decimals() public view override returns (uint8) {
        return dec;
    }
}
