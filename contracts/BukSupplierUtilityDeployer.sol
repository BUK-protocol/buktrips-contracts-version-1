// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/utils/Context.sol";
import "./SupplierUtilityContract.sol";

/**
* @author BUK Technology Inc
* @title BUK Protocol Supplier Utility Deployer Contract
* @dev Contract to deploy instances of the SupplierContractUtility contract
*/
contract BukSupplierUtilityDeployer is Context {

    /**
    * @dev Address of the contract's admin
    */
    address internal admin;
    /**
    * @dev Address of the factory contract
    */
    address internal factory_contract;

    /**
    * @dev Event emitted when a new Supplier contract utility is deployed
    * @param id ID of the deployed supplier utility
    * @param supplier_utility_contract Address of the deployed supplier contract utility
    */
    event SupplierUtilityDeploy(uint256 indexed id, address indexed supplier_utility_contract);
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
    * @dev Function to deploy a new instance of the Supplier contract utility
    * @param id ID of the new supplier utility
    * @param _name Name of the new supplier utility
    * @param _contract_uri URI of the new supplier contract utility
    * @return Address of the deployed Supplier contract utility
    * @notice This function can only be called by factory contract
    */
    function deploySupplierUtility(uint256 id, string memory _name, string memory _contract_uri) external onlyFactory(_msgSender()) returns (address) {
        SupplierUtilityContract supplier;
        supplier = new SupplierUtilityContract(id, _name, factory_contract, _contract_uri);
        emit SupplierUtilityDeploy(id, address(supplier));
        return address(supplier);
    }
}
