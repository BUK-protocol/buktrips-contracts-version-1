import * as hre from "hardhat";
import { CONTRACT } from "../utils/config";

async function main() {

  //Deploy Factory Contract
  const Factory = await hre.ethers.getContractFactory("BukTrips");
  const factory = await Factory.deploy(CONTRACT.TREASURY_CONTRACT as string, CONTRACT.USDC_CONTRACT as string, CONTRACT.BUK_WALLET as string);
  await factory.deployed();
  console.log(`Factory Contract is deployed at ${factory.address}`);

  // wait for 5 block transactions to ensure deployment before verifying
  await factory.deployTransaction.wait(5);

  //Deploy Supplier Deployer
  const SupplierDeployer = await hre.ethers.getContractFactory("BukSupplierDeployer");
  const supplier_deployer = await SupplierDeployer.deploy(factory.address);
  await supplier_deployer.deployed();
  console.log(`Supplier Deployer Contract is deployed at ${supplier_deployer.address}`);

  // wait for 5 block transactions to ensure deployment before verifying
  await supplier_deployer.deployTransaction.wait(5);

  //Deploy Supplier Utility Deployer
  const SupplierUtilityDeployer = await hre.ethers.getContractFactory("BukSupplierUtilityDeployer");
  const supplier_utility_deployer = await SupplierUtilityDeployer.deploy(factory.address);
  await supplier_utility_deployer.deployed();
  console.log(`Supplier Utility Deployer Contract is deployed at ${supplier_utility_deployer.address}`);

  // wait for 5 block transactions to ensure deployment before verifying
  await supplier_utility_deployer.deployTransaction.wait(5);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
