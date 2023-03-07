// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/utils/Context.sol";
import "./SupplierContract.sol";

/**
 *@author BUK Technology Inc 
 *@title BUK Protocol Supplier Deployer Contract
 *@dev Contract to deploy instances of the SupplierContract contract
*/
contract BukSupplierDeployer is Context {

    /**
    * @dev Address of the contract's admin
    */
    address internal admin;
    /**
    * @dev Address of the factory contract
    */
    address internal factory_contract;

    /**
    * @dev Event emitted when a new Supplier contract is deployed
    * @param id ID of the deployed supplier
    * @param supplier_contract Address of the deployed supplier contract
    */
    event SupplierDeploy(uint256 indexed id, address indexed supplier_contract);
    /**
    * @dev Event emitted when the factory contract is updated
    * @param deployer_contract Address of the deployer contract
    * @param factory_contract Address of the updated factory contract
    */
    event DeployerFactoryUpdated(address indexed deployer_contract, address indexed factory_contract);

    /**
    @dev Modifier to allow access only to the factory contract
    @param addr Address to verify
    */
    modifier onlyAdmin(address addr) {
        require(addr == admin, "Only Admin contract has the access");
        _;
    }
    /**
    * @dev Modifier to allow access only to the admin
    * @param addr Address to verify
    */
    modifier onlyFactory(address addr) {
        require(addr == factory_contract, "Only Factory contract has the access");
        _;
    }

    /**
    * @dev Contract constructor, sets the factory contract address
    * @param _factory_contract Address of the factory contract
    */
    constructor( address _factory_contract ) {
        factory_contract = _factory_contract;
        admin = _msgSender();
    }

    /**
    * @dev Function to update the factory contract address
    * @param _factory_contract Address of the updated factory contract
    * @notice This function can only be called by admin
    */
    function updateFactory(address _factory_contract) external onlyAdmin(_msgSender()) {
        factory_contract = _factory_contract;
        emit DeployerFactoryUpdated(address(this), factory_contract);
    }

    /**
    * @dev Function to deploy a new instance of the Supplier contract
    * @param id ID of the new supplier
    * @param _name Name of the new supplier
    * @param _supplier_owner Address of the owner of the new supplier
    * @param _utility_contract_addr Address of the utility contract for the new supplier
    * @param _contract_uri URI of the new supplier contract
    * @return Address of the deployed Supplier contract
    * @notice This function can only be called by factory contract
    */
    function deploySupplier(string memory _contract_name, uint256 id, string memory _name, address _supplier_owner, address _utility_contract_addr, string memory _contract_uri) public onlyFactory(_msgSender()) returns (address) {
        SupplierContract supplier;
        supplier = new SupplierContract(_contract_name, id, _name, _supplier_owner, _utility_contract_addr, factory_contract, _contract_uri);
        emit SupplierDeploy(id, address(supplier));
        return address(supplier);
    }
}
