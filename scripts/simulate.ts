import { ethers } from "hardhat";
import { Signer } from "ethers";
import * as fs from "fs";
import {
  deploySimpleFactory,
  createSimpleLeverage,
  deployMockToken,
  deployMockAAVEPool,
  deployAAVEProvider,
  deployMockUniswapV3Pool,
  deployMockWETH,
} from "../instructions";
import {
  MockAAVEPool,
  MockToken,
  MockUniswapV3Pool,
  MockWETH,
  SimpleFactory,
  SimpleLeverage,
} from "../typechain-types";

import { ADDRESS_PATH } from "./utils";

const ADDRESSES = require("../" + ADDRESS_PATH);


async function main() {
  let admin: Signer, userA: Signer;

  [admin, userA] = await ethers.getSigners();

  let leverage: SimpleLeverage;
  const LOAN_AMOUNT = ethers.utils.parseEther("500");
  const ETH_AMOUNT = ethers.utils.parseEther("0.1");

  leverage = await ethers.getContractAt("SimpleLeverage", ADDRESSES.Leverage);
  await (await leverage.connect(userA).leverage(LOAN_AMOUNT, { value: ETH_AMOUNT })).wait();
  await (await leverage.connect(userA).deleverage()).wait();

  fs.writeFileSync(ADDRESS_PATH, JSON.stringify(ADDRESSES, null, 4), "utf8");
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
