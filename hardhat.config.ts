import { HardhatUserConfig, task } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";
import * as dotenv from "dotenv";

import { chainIds } from "./constants";
import { NetworkUserConfig } from "hardhat/types";

dotenv.config();

const infuraApiKey: string | undefined = process.env.INFURA_API_KEY;
if (!infuraApiKey) {
  throw new Error("Please set your INFURA_API_KEY in a .env file");
}

function getChainConfig(network: keyof typeof chainIds): NetworkUserConfig {
  let accounts: string[] = [];
  for (let i = 0; i < 10; i++) {
    const privateKey: string | undefined = process.env["PRIVATE_KEY_" + i.toString()];
    if (privateKey) {
      accounts.push(privateKey);
    }
  }
  const url: string = "https://" + network + ".infura.io/v3/" + infuraApiKey;
  return {
    accounts,
    chainId: chainIds[network],
    url,
    gas: 10000000,
    blockGasLimit: 100000000,
  };
}

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.10",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },
  networks: {
    matic: {
      url: "https://rpc-mumbai.matic.today", // https://rpc-mumbai.maticvigil.com/
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      timeout: 60000,
      gas: 10000000,
      blockGasLimit: 100000000,
    },
    goerli: getChainConfig("goerli"),
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  mocha: {
    timeout: 40000,
  },
};

export default config;
