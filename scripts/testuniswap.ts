import { expect } from "chai";
import { BigNumber } from "ethers";
import { ethers } from "hardhat";

const DAI_WHALE = "0x1B7BAa734C00298b9429b518D621753Bb0f6efF2";
const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const WBTC = "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599";
const MY_ACCOUNT = "0x65F7eD731931EA40d58ADE6F859E249a95f92d28";

const main = async () => {
  const WHALE = DAI_WHALE;
  const AMOUNT_IN = ethers.utils.parseEther("1000000");
  const AMOUNT_OUT_MIN = BigNumber.from(1);
  const TOKEN_IN = DAI;
  const TOKEN_OUT = WBTC;
  const TO = MY_ACCOUNT;
  const tokenIn = await ethers.getContractAt("ERC20", TOKEN_IN);
  const tokenOut = await ethers.getContractAt("ERC20", TOKEN_OUT);

  const [deployer] = await ethers.getSigners();
  const TestUniswapFactory = await ethers.getContractFactory(
    "TestUniswap",
    deployer
  );
  const testUniswap = await TestUniswapFactory.deploy();
  await testUniswap.deployed();

  const impersonatedDAIWhaleSigner = await ethers.getImpersonatedSigner(WHALE);

  // whale approves 1 mil dai
  await tokenIn
    .connect(impersonatedDAIWhaleSigner)
    .approve(testUniswap.address, AMOUNT_IN);
  await testUniswap
    .connect(impersonatedDAIWhaleSigner)
    .swap(
      tokenIn.address,
      tokenOut.address,
      AMOUNT_IN,
      AMOUNT_OUT_MIN,
      MY_ACCOUNT
    );

  console.log(`out ${await tokenOut.balanceOf(MY_ACCOUNT)}`);

  // await tokenIn.connect(deployer).approve(testUniswap.address, AMOUNT_IN, {from: })
};

main();
