import * as hre from "hardhat";
import { Web3Service } from "../utils/functions/web3";
import { CONTRACT } from "../utils/config";

async function main() {
  //To set the Factory in Treasury Contract
  const web3Service = new Web3Service()
  const treasuryResult = await web3Service.setTreasuryFactory()
  console.log("Factory contract is set in Treasury Contract - ", treasuryResult)
  
  //To set deployers in Factory Contract
  const deployerResult = await web3Service.setDeployers()
  console.log("Set Deployers in Factory Contract - ", deployerResult)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
