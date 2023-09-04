import { assert, expect } from "chai";
import { BigNumber, Signer } from "ethers";
import { ethers } from "hardhat";
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

const START_PRICE = 1500; // 1 eth = 1500 usdc
const MINT_AMOUNT = ethers.utils.parseEther("10000");

describe("SimpleLeverage", async function () {
  let admin: Signer, userA: Signer, userB: Signer, userC: Signer, userD: Signer, userE: Signer, userF: Signer;
  let factory: SimpleFactory;
  let USDC: MockToken;
  let mockAAVEPool: MockAAVEPool;
  let mockUniswapV3Pool: MockUniswapV3Pool;
  let mockWETH0: MockWETH; // WETH for AAVE
  let mockWETH1: MockWETH; // WETH for Uniswap

  before(async () => {
    [admin, userA, userB, userC, userD, userE, userF] = await ethers.getSigners();

    USDC = await deployMockToken("USD Coin", "USDC", 18);
    mockWETH0 = await deployMockWETH();
    mockWETH1 = await deployMockWETH();
    mockAAVEPool = await deployMockAAVEPool();
    let aaveProvider = await deployAAVEProvider(mockAAVEPool.address, await admin.getAddress());
    mockUniswapV3Pool = await deployMockUniswapV3Pool(mockWETH1.address, USDC.address);

    factory = await deploySimpleFactory(
      USDC.address,
      aaveProvider.address,
      mockUniswapV3Pool.address,
      mockWETH0.address,
    );

    await (await USDC.mintTo(mockAAVEPool.address, MINT_AMOUNT)).wait();
    await (await USDC.mintTo(mockUniswapV3Pool.address, MINT_AMOUNT)).wait();
    await (await mockWETH0.mintTo(mockAAVEPool.address, MINT_AMOUNT.div(START_PRICE))).wait();
    await (await mockWETH1.mintTo(mockUniswapV3Pool.address, MINT_AMOUNT.div(START_PRICE))).wait();
    await mockWETH0.connect(userE).deposit({ value: ethers.utils.parseEther("8") });
    await mockWETH1.connect(userF).deposit({ value: ethers.utils.parseEther("8") });

    console.log({
      USDC: USDC.address,
      WETH_AAVE: mockWETH0.address,
      WETH_Uniswap: mockWETH1.address,
    });
  });

  it("create Leverage", async function () {
    let leverage: SimpleLeverage;
    leverage = await createSimpleLeverage(factory.address, userC);
    console.log("Leverage Created: ", leverage.address);
  });

  describe("SimpleLeverage", async function () {
    let leverage: SimpleLeverage;
    const LOAN_AMOUNT = ethers.utils.parseEther("500");
    const ETH_AMOUNT = ethers.utils.parseEther("0.1");

    before(async () => {
      leverage = await createSimpleLeverage(factory.address, userA);
    });
    it("leverage", async function () {
      const balanceBefore = await ethers.provider.getBalance(await userA.getAddress());
      await expect(leverage.connect(userA).leverage(LOAN_AMOUNT, { value: ETH_AMOUNT })).to.emit(leverage, "Leveraged");
      const balanceAfter = await ethers.provider.getBalance(await userA.getAddress());
      console.log({ balanceBefore, balanceAfter });
    });
    it("deleverage", async function () {
      const balanceBefore = await ethers.provider.getBalance(await userA.getAddress());
      await expect(leverage.connect(userA).deleverage()).to.emit(leverage, "Deleveraged");
      const balanceAfter = await ethers.provider.getBalance(await userA.getAddress());
      console.log({ balanceBefore, balanceAfter });
    });
  });
});
