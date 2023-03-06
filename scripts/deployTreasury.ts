import * as hre from "hardhat";
import { CONTRACT } from "../utils/config";

async function main() {
  const Treasury = await hre.ethers.getContractFactory("Treasury");
  const treasury = await Treasury.deploy(CONTRACT.USDC_CONTRACT as string);

  await treasury.deployed();

  // wait for 5 block transactions to ensure deployment before verifying
  await treasury.deployTransaction.wait(5);

  console.log(`Treasury Contract is deployed at ${treasury.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
