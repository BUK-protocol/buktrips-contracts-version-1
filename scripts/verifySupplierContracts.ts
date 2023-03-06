import * as hre from "hardhat";
import { CONTRACT } from "../utils/config";

async function main() {
  
  const data = {
    id: 1,
    name: "Expedia Group Inc.",
    uri: "https://ipfs.io/ipfs/bafkreia3cbw2xztf2xyl4ivuxhbtxa3xjlbpvk4eyolbkzhlnpnclgsa3q",
  }

  //Verify Supplier Contract
  await hre.run("verify:verify", {
    address: CONTRACT.SUPPLIER_CONTRACT,
    contract: "contracts/SupplierContract.sol:SupplierContract", 
    constructorArguments: [
      data.id,
      data.name, 
      CONTRACT.BUK_WALLET, 
      CONTRACT.SUPPLIER_UTILITY_CONTRACT,
      CONTRACT.FACTORY_CONTRACT,
      data.uri 
    ],
  });

  //Verify Supplier Utility Contract
  await hre.run("verify:verify", {
    address: CONTRACT.SUPPLIER_UTILITY_CONTRACT,
    contract: "contracts/SupplierUtilityContract.sol:SupplierUtilityContract", 
    constructorArguments: [
      data.id,
      data.name, 
      CONTRACT.FACTORY_CONTRACT,
      data.uri 
    ],
  });

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
