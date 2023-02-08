import { ethers } from "hardhat";

describe("Test AMM Core", async () => {
  let deployerAddress,
    erc20deployerAddress,
    ammAddress,
    userAAddress,
    userBAddress,
    ammContract,
    tokenAContract,
    tokenBContract;
  beforeEach(async () => {
    [deployerAddress, userAAddress, userBAddress, erc20deployerAddress] =
      await ethers.getSigners();

    // deploying AMM contract
    const ammContractFactory = await ethers.getContractFactory(
      "CPAMM",
      deployerAddress
    );
    ammContract = await ammContractFactory.deploy();
    await ammContract.deployed();
    ammAddress = ammContract.address;

    // deploying Token A, Token B
    const tokenFactory = await ethers.getContractFactory(
      "MockERC20",
      erc20deployerAddress
    );

    tokenAContract = await tokenFactory.deploy();
    await tokenAContract.deployed();

    tokenBContract = await tokenFactory.deploy();
    await tokenBContract.deployed();
  });
});
