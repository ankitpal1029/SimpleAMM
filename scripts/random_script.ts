import { ethers } from "hardhat";

const main = async () => {
  const [deployer, receiver] = await ethers.getSigners();
  //   const RandomFactory = await ethers.getContractFactory("Random", deployer);
  //   const randomContract = await RandomFactory.deploy();

  //   const tx = await randomContract.returnFunction();
  //   console.log(tx);
  //   const receipt = await tx.wait();
  //   console.log(receipt.events);

  //   const tx = await randomContract.wait();
  //   console.log(tx);

  const provider = new ethers.providers.JsonRpcProvider(
    "http://127.0.0.1:8545/"
  );

  const val = await provider.getBalance(deployer.address);
  console.log(`ETH balance of ${deployer.address} is ${val.toString()}`);
  const tx = await deployer.sendTransaction({
    to: receiver.address,
    value: ethers.utils.parseEther("20"),
  });
  const receipt = await tx.wait();
  console.log(receipt);
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
