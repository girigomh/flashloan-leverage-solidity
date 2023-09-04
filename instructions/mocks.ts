import { artifacts, ethers } from "hardhat";
import { MockAAVEPool__factory } from "../typechain-types";

export async function deployMockToken(name: string, symbol: string, decimals: number) {
  const mockTokenFactory = await ethers.getContractFactory("MockToken");
  const mockToken = await mockTokenFactory.deploy(name, symbol, decimals);
  await mockToken.deployed();
  return mockToken;
}

export async function deployMockAAVEPool() {
  const mockAAVEPoolFactory = await ethers.getContractFactory("MockAAVEPool");
  const mockAAVEPool = await mockAAVEPoolFactory.deploy();
  await mockAAVEPool.deployed();
  return mockAAVEPool;
}

export async function deployAAVEProvider(pool: string, owner: string) {
  const aaveProviderFactory = await ethers.getContractFactory("PoolAddressesProvider");
  const aaveProvider = await aaveProviderFactory.deploy("MARKET_ID", owner);
  await aaveProvider.deployed();
  await (await aaveProvider.setAddress(ethers.utils.formatBytes32String("POOL"), pool)).wait();
  return aaveProvider;
}

export async function deployMockUniswapV3Pool(token0: string, token1: string) {
  const mockUniswapV3PoolFactory = await ethers.getContractFactory("MockUniswapV3Pool");
  const mockUniswapV3Pool = await mockUniswapV3PoolFactory.deploy(token0, token1);
  await mockUniswapV3Pool.deployed();
  return mockUniswapV3Pool;
}

export async function deployMockWETH() {
  const mockWETHFactory = await ethers.getContractFactory("MockWETH");
  const mockWETH = await mockWETHFactory.deploy();
  await mockWETH.deployed();
  return mockWETH;
}
