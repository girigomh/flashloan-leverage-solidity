import { BigNumber, Signer } from "ethers";
import { artifacts, ethers } from "hardhat";
import { SimpleFactory } from "../typechain-types";
export * from "./mocks";

export async function deploySimpleFactory(
  token: string,
  aaveProvider: string,
  uniswapV3Pool: string,
  aaveWETH: string,
) {
  const simpleFactoryFactory = await ethers.getContractFactory("SimpleFactory");
  const simpleFactory = await simpleFactoryFactory.deploy(token, aaveProvider, uniswapV3Pool, aaveWETH);
  await simpleFactory.deployed();
  return simpleFactory;
}

export async function createSimpleLeverage(simpleFactoryAddress: string, user: Signer) {
  const simpleFactory = await ethers.getContractAt("SimpleFactory", simpleFactoryAddress);
  const tx = await simpleFactory.connect(user).createLeverage();
  const event = (await tx.wait()).events?.find(event => event.event === "LeverageCreated");
  const simpleLeverageAddress = event?.args?.leverage;
  const simpleLeverage = await ethers.getContractAt("SimpleLeverage", simpleLeverageAddress);
  return simpleLeverage;
}
