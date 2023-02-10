import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { deploySetupFixture } from "./fixtures/deploySetupFixture";

describe("Test AMM Core", async () => {
  describe("Test Add Liquidity", async () => {
    it("should emit add liquidity event", async () => {
      const {
        deployer,
        erc20deployer,
        userA,
        userB,
        ammContract,
        tokenAContract,
        tokenBContract,
      } = await loadFixture(deploySetupFixture);

      const liquidityTokenA = ethers.utils.parseEther("10");
      const liquidityTokenB = ethers.utils.parseEther("10");
      await tokenAContract
        .connect(userA)
        .approve(ammContract.address, liquidityTokenA);
      await tokenBContract
        .connect(userA)
        .approve(ammContract.address, liquidityTokenB);

      await expect(
        await ammContract
          .connect(userA)
          .addLiquidity(liquidityTokenA, liquidityTokenB)
      )
        .to.emit(ammContract, "LiquidityAdded")
        .withArgs(
          liquidityTokenA,
          liquidityTokenA,
          liquidityTokenB,
          userA.address
        );
    });

    it("should increase totalSupply and reserves", async () => {
      const {
        deployer,
        erc20deployer,
        userA,
        userB,
        ammContract,
        tokenAContract,
        tokenBContract,
      } = await loadFixture(deploySetupFixture);
      const liquidityTokenA = ethers.utils.parseEther("10");
      const liquidityTokenB = ethers.utils.parseEther("10");
      await tokenAContract
        .connect(userA)
        .approve(ammContract.address, liquidityTokenA);
      await tokenBContract
        .connect(userA)
        .approve(ammContract.address, liquidityTokenB);
      await ammContract
        .connect(userA)
        .addLiquidity(liquidityTokenA, liquidityTokenB);

      expect(await ammContract.totalSupply()).to.deep.equal(
        ethers.utils.parseEther("20")
      );

      expect(await ammContract.reserve0()).to.deep.equal(
        ethers.utils.parseEther("20")
      );

      expect(await ammContract.reserve1()).to.deep.equal(
        ethers.utils.parseEther("20")
      );
    });
  });

  describe("Test Removing Liquidity", async () => {
    it("Should emit Remove Liquidity event", async () => {
      const {
        deployer,
        erc20deployer,
        userA,
        userB,
        ammContract,
        tokenAContract,
        tokenBContract,
      } = await loadFixture(deploySetupFixture);
      // ammContract.connect(deployer).removeLiquidity()
    });
  });
});
