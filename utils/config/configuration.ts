import * as dotenv from 'dotenv';
dotenv.config();

export const CONTRACT = {
  FACTORY_CONTRACT: process.env.FACTORY_CONTRACT || '',
  SUPPLIER_DEPLOYER_CONTRACT: process.env.SUPPLIER_DEPLOYER_CONTRACT || '',
  SUPPLIER_UTILITY_DEPLOYER_CONTRACT: process.env.SUPPLIER_UTILITY_DEPLOYER_CONTRACT || '',
  USDC_CONTRACT: process.env.USDC_CONTRACT || '',
  TREASURY_CONTRACT: process.env.TREASURY_CONTRACT || '',
  BUK_WALLET: process.env.BUK_WALLET || '',
  SUPPLIER_CONTRACT: process.env.SUPPLIER_CONTRACT || '',
  SUPPLIER_UTILITY_CONTRACT: process.env.SUPPLIER_UTILITY_CONTRACT || '',
};
export const API_KEYS = {
  POLYGONSCAN_API_KEY: process.env.POLYGONSCAN_API_KEY || '',
}
export const WALLET = {
  PRIVATE_KEY: process.env.PRIVATE_KEY || '',
};
