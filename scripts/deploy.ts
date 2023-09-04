import { ethers } from "hardhat";
import * as fs from "fs";

import { deploySimpleFactory } from "../instructions";
import { ADDRESS_PATH } from "./utils";

const ADDRESSES = require("../" + ADDRESS_PATH);

const USDC = "";
const AAVE_PROVIDER = "";
const UNISWAP_V3_POOL = "";
const AAVE_WETH = "";

async function main() {
  const simpleFactory = await deploySimpleFactory(USDC, AAVE_PROVIDER, UNISWAP_V3_POOL, AAVE_WETH);
  ADDRESSES.Factory = simpleFactory.address;

  fs.writeFileSync(ADDRESS_PATH, JSON.stringify(ADDRESSES, null, 4), "utf8");
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
