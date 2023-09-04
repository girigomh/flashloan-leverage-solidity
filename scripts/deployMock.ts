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

const START_PRICE = 1500; // 1 eth = 1500 usdc
const MINT_AMOUNT = ethers.utils.parseEther("10000");

async function main() {
  let admin: Signer, userA: Signer;
  let factory: SimpleFactory;
  let USDC: MockToken;
  let mockAAVEPool: MockAAVEPool;
  let mockUniswapV3Pool: MockUniswapV3Pool;
  let mockWETH0: MockWETH; // WETH for AAVE
  let mockWETH1: MockWETH; // WETH for Uniswap

  [admin, userA] = await ethers.getSigners();

  USDC = await deployMockToken("USD Coin", "USDC", 18);
  mockWETH0 = await deployMockWETH();
  mockWETH1 = await deployMockWETH();
  mockAAVEPool = await deployMockAAVEPool();
  let aaveProvider = await deployAAVEProvider(mockAAVEPool.address, await admin.getAddress());
  mockUniswapV3Pool = await deployMockUniswapV3Pool(mockWETH1.address, USDC.address);

  factory = await deploySimpleFactory(USDC.address, aaveProvider.address, mockUniswapV3Pool.address, mockWETH0.address);

  await (await USDC.mintTo(mockAAVEPool.address, MINT_AMOUNT)).wait();
  await (await USDC.mintTo(mockUniswapV3Pool.address, MINT_AMOUNT)).wait();
  await (await mockWETH0.mintTo(mockAAVEPool.address, MINT_AMOUNT.div(START_PRICE))).wait();
  await (await mockWETH1.mintTo(mockUniswapV3Pool.address, MINT_AMOUNT.div(START_PRICE))).wait();
  await mockWETH0.deposit({ value: ethers.utils.parseEther("1") });
  await mockWETH1.deposit({ value: ethers.utils.parseEther("1") });

  console.log({
    USDC: USDC.address,
    WETH_AAVE: mockWETH0.address,
    WETH_Uniswap: mockWETH1.address,
  });

  let leverage: SimpleLeverage;
  const LOAN_AMOUNT = ethers.utils.parseEther("500");
  const ETH_AMOUNT = ethers.utils.parseEther("0.1");

  leverage = await createSimpleLeverage(factory.address, userA);

  ADDRESSES.Factory = factory.address;
  ADDRESSES.Leverage = leverage.address;
  ADDRESSES.Factory = factory.address;
  ADDRESSES.USDC = USDC.address;
  ADDRESSES.MockWETH0 = mockWETH0.address;
  ADDRESSES.MockWETH1 = mockWETH1.address;
  ADDRESSES.MockAAVEPool = mockAAVEPool.address;
  ADDRESSES.AaveProvider = aaveProvider.address;
  ADDRESSES.MockUniswapV3Pool = mockUniswapV3Pool.address;
  console.log(ADDRESSES);

  fs.writeFileSync(ADDRESS_PATH, JSON.stringify(ADDRESSES, null, 4), "utf8");
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
