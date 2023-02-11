import { ethers } from "hardhat";

const main = async () => {
  const [deployer] = await ethers.getSigners();
  const RandomFactory = await ethers.getContractFactory("Random", deployer);
  const randomContract = await RandomFactory.deploy();

  const tx = await randomContract.randomFunction();
  const receipt = await tx.wait();
  console.log(receipt.events);

  //   const tx = await randomContract.wait();
  //   console.log(tx);
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
