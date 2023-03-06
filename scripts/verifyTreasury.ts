import * as hre from "hardhat";
import { CONTRACT } from "../utils/config";

async function main() {
  await hre.run("verify:verify", {
    address: CONTRACT.TREASURY_CONTRACT,
    contract: "contracts/Treasury.sol:Treasury", 
    constructorArguments: [
      CONTRACT.USDC_CONTRACT as string
    ],
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
