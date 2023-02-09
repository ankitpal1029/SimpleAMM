import { ethers } from "hardhat";
import { MockERC20__factory } from "../../../typechain-types";

export const deploySetupFixture = async () => {
  let deployer,
    erc20deployer,
    // ammAddress,
    userA,
    userB,
    ammContract,
    tokenAContract,
    tokenBContract;
  [deployer, userA, userB, erc20deployer] = await ethers.getSigners();

  // deploying Token A, Token B
  const tokenFactory: MockERC20__factory = await ethers.getContractFactory(
    "MockERC20",
    erc20deployer
  );

  const amountToMint = await ethers.utils.parseEther("1000");

  tokenAContract = await tokenFactory.deploy(
    "ERCA",
    "A",
    deployer.address,
    amountToMint
  );
  await tokenAContract.deployed();

  tokenBContract = await tokenFactory.deploy(
    "ERCB",
    "B",
    deployer.address,
    amountToMint
  );
  await tokenBContract.deployed();

  // deploying AMM contract
  const ammContractFactory = await ethers.getContractFactory("CPAMM", deployer);
  ammContract = await ammContractFactory.deploy(
    tokenAContract.address,
    tokenBContract.address
  );
  await ammContract.deployed();
  // ammAddress = ammContract.address;

  // add Liquidity for token A and token B
  const liquidityTokenA = ethers.utils.parseEther("10");
  const liquidityTokenB = ethers.utils.parseEther("10");

  await tokenAContract
    .connect(deployer)
    .approve(ammContract.address, liquidityTokenA);
  await tokenBContract
    .connect(deployer)
    .approve(ammContract.address, liquidityTokenB);

  await ammContract
    .connect(deployer)
    .addLiquidity(liquidityTokenA, liquidityTokenB);

  // transfer 250 token A and 250 token B each to user A and user B
  await tokenAContract
    .connect(deployer)
    .transfer(userA.address, ethers.utils.parseEther("250"));
  await tokenAContract
    .connect(deployer)
    .transfer(userB.address, ethers.utils.parseEther("250"));

  await tokenBContract
    .connect(deployer)
    .transfer(userA.address, ethers.utils.parseEther("250"));
  await tokenBContract
    .connect(deployer)
    .transfer(userB.address, ethers.utils.parseEther("250"));

  return {
    deployer,
    erc20deployer,
    userA,
    userB,
    ammContract,
    tokenAContract,
    tokenBContract,
  };
};
