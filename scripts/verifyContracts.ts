import * as hre from "hardhat";
import { CONTRACT } from "../utils/config";

async function main() {
  //Verify Factory Contract
  await hre.run("verify:verify", {
    address: CONTRACT.FACTORY_CONTRACT,
    contract: "contracts/FactoryContract.sol:BukTrips", 
    constructorArguments: [
      CONTRACT.TREASURY_CONTRACT as string, 
      CONTRACT.USDC_CONTRACT as string, 
      CONTRACT.BUK_WALLET as string
    ],
  });

  //Verify Supplier Deployer Contract
  await hre.run("verify:verify", {
    address: CONTRACT.SUPPLIER_DEPLOYER_CONTRACT,
    contract: "contracts/BukSupplierDeployer.sol:BukSupplierDeployer", 
    constructorArguments: [
      CONTRACT.FACTORY_CONTRACT
    ],
  });

  //Verify Supplier Utility Deployer Contract
  await hre.run("verify:verify", {
    address: CONTRACT.SUPPLIER_UTILITY_DEPLOYER_CONTRACT,
    contract: "contracts/BukSupplierUtilityDeployer.sol:BukSupplierUtilityDeployer", 
    constructorArguments: [
      CONTRACT.FACTORY_CONTRACT
    ],
  });

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
