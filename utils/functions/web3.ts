import {ethers, Contract} from 'ethers';
import { CONTRACT, WALLET } from '../config';
import { activeChainId, getRPCProvider } from '../constants/chainConfig';
import FACTORY from '../../artifacts/contracts/FactoryContract.sol/BukTrips.json';
import TREASURY from '../../artifacts/contracts/Treasury.sol/Treasury.json';

export class Web3Service {
  getWalletData() {
    const key = WALLET.PRIVATE_KEY;
    const provider = new ethers.providers.JsonRpcProvider(
      getRPCProvider(activeChainId),
    );
    const wallet = new ethers.Wallet(key, provider);
    const walletSigner = new ethers.Wallet(key, provider).provider;
    return {
      address: wallet.address,
      provider,
      signer: wallet,
    };
  }

  getContract(contractAddress: string, abi: any): Contract {
    const contract = new ethers.Contract(
      contractAddress,
      abi,
      this.getWalletData().signer,
    );
    return contract;
  }

  async setTreasuryFactory() {
    const contract = this.getContract(CONTRACT.TREASURY_CONTRACT, TREASURY.abi);
    const result = await contract.setFactory(CONTRACT.FACTORY_CONTRACT);
    const receipt = await result.wait()
    const dataDecode = contract.interface.decodeFunctionData("setFactory(address)", result.data)
    console.log("🚀 ~ file: web3.ts:37 ~ Web3Service ~ setTreasuryFactory ~ dataDecode", dataDecode)
    return receipt?.transactionHash
  }

  async setDeployers() {
    const contract = this.getContract(CONTRACT.FACTORY_CONTRACT, FACTORY.abi);
    const result = await contract.setDeployers(CONTRACT.SUPPLIER_DEPLOYER_CONTRACT, CONTRACT.SUPPLIER_UTILITY_DEPLOYER_CONTRACT);
    const dataDecode = contract.interface.decodeFunctionData("setDeployers(address,address)", result.data)
    console.log("🚀 ~ file: web3.ts:37 ~ Web3Service ~ setDeployers ~ dataDecode", dataDecode)
    const receipt = await result.wait()
    return receipt?.transactionHash
  }

  async registerSupplier(_name: string, _supplier_owner: string, _contract_uri: string): Promise<{tx: string,id: number, supplier_contract: string, utility_contract: string}> {
    const contract = this.getContract(CONTRACT.FACTORY_CONTRACT, FACTORY.abi);
    const result = await contract.registerSupplier(_name, _supplier_owner, _contract_uri);
    const receipt = await result.wait()
    let eventData: any = {}
    for (const event of receipt.events) {
      try {
        if(event.event === 'RegisterSupplier') {
          eventData = event.args
        }
      } catch (error) {
      }
    }
    return {tx: receipt?.transactionHash, id: eventData?.id, supplier_contract: eventData?.supplier_contract, utility_contract: eventData?.utility_contract}
  }
}
