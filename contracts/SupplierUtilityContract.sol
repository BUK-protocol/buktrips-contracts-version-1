// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
* @title Supplier Utility Contract
* @author BukTrips Technologies
* @dev Contract for managing supplier data and ERC1155 token management for utility tickets
*/
contract SupplierUtilityContract is AccessControl, ERC1155 {

    /**
    * @dev address of the utility contract
    */
    address public supplier_contract;
    /**
    * @dev Contract URI string
    */
    string internal contract_uri;

    /**
    * @dev Struct for supplier data
    * @var id Supplier ID
    * @var name Supplier name
    */
    struct Supplier_Data {
        uint256 id;
        string name;
    }

    /**
    * @dev Supplier data instance
    */
    Supplier_Data public Details;

    /**
    * @dev Mapping for token URI's for booked tickets
    */
    mapping(uint256 => string) public bookingTickets; //tokenID -> uri

    /**
    * @dev Constant for the role of the supplier contract
    */
    bytes32 public constant SUPPLIER_CONTRACT_ROLE = keccak256("SUPPLIER_CONTRACT");
    /**
    * @dev Constant for the role of the factory contract
    */
    bytes32 public constant FACTORY_CONTRACT_ROLE = keccak256("FACTORY_CONTRACT");

    /**
    * @dev Event to set the contract URI
    */
    event SetContractURI(string indexed contract_uri);
    /**
    * @dev Event to grant supplier contract role
    */
    event GrantSupplierRole(address indexed supplier);
    /**
    * @dev Event to update the supplier details
    */
    event UpdateSupplierDetails(string indexed name);
    /**
    * @dev Event to set token URI
    */
    event SetURI(uint indexed id, string indexed uri);
    /**
    * @dev Event to mint NFT
    */
    event Mint(uint256 indexed id, uint256 indexed amount, address indexed to);
    /**
    * @dev Custom error in the function to transfer NFTs.
    */
   error NonTransferable(string message);

    /**
    * @dev Constructor to initialize the contract
    * @param _id Supplier ID
    * @param _name Supplier name
    * @param _factory_contract Address of the factory contract
    * @param _contract_uri Contract URI string
    */
    constructor(uint256 _id, string memory _name, address _factory_contract, string memory _contract_uri) ERC1155("") {
        Details.id = _id;
        Details.name = _name;
        contract_uri = _contract_uri;
        _grantRole(FACTORY_CONTRACT_ROLE, _factory_contract);
    }

    /**
    * @dev Function to grant the supplier role to a given contract
    * @param _supplier_contract address: The address of the supplier contract
    * @notice This function can only be called by a contract with `FACTORY_CONTRACT_ROLE`
    */
    function grantSupplierRole(address _supplier_contract) public onlyRole(FACTORY_CONTRACT_ROLE)  {
        supplier_contract = _supplier_contract;
        _grantRole(SUPPLIER_CONTRACT_ROLE, _supplier_contract);
        emit GrantSupplierRole(_supplier_contract);
    }

    /**
    * @dev Function to set the contract URI
    * @param _contract_uri string: The new URI of the contract
    * @notice This function can only be called by a contract with `SUPPLIER_CONTRACT_ROLE`
    */
    function setContractURI(string memory _contract_uri) public onlyRole(SUPPLIER_CONTRACT_ROLE) {
        contract_uri = _contract_uri;
        emit SetContractURI(contract_uri);
    }
   
    /**
    * @dev Function to get the contract URI
    * @return uri - The URI of the contract
    */
    function contractURI() public view returns (string memory) {
        return contract_uri;
    }

    /**
    * @dev Function to get the supplier details
    * @return name - The name of the supplier
    */
    function getSupplierDetails() public view returns (string memory name) {
        return (Details.name);
    }
    
    /**
    * @dev Function to update the supplier details
    * @param name string: The new name of the supplier
    * @notice This function can only be called by a contract with `SUPPLIER_CONTRACT_ROLE`
    */
    function updateSupplierDetails(string memory name) public onlyRole(SUPPLIER_CONTRACT_ROLE) {
        Details.name = name;
        emit UpdateSupplierDetails(name);
    }

    /**
    * @dev Function to get the URI for a given ID
    * @param id uint256: The ID of the token
    * @return id - The URI of the token
    */
    function uri(uint256 id) public view virtual override returns (string memory) {
        return bookingTickets[id];
    }

    /**
    * @dev Function to set the URI for a given ID
    * @param _id uint256: The ID of the token
    * @param _newuri string: The new URI of the token
    * @notice This function can only be called by a contract with `FACTORY_CONTRACT_ROLE`
    */
    function setURI(uint256 _id, string memory _newuri) external onlyRole(FACTORY_CONTRACT_ROLE) {
        _setURI(_id,_newuri);
        emit SetURI(_id,_newuri);
    }

    /**
    * @dev Function to mint tokens
    * @param account address: The address to which the tokens will be minted
    * @param _id uint256: The ID of the token
    * @param amount uint256: The amount of tokens to be minted
    * @param _newuri string: The URI of the token
    * @param data bytes: Additional data associated with the token
    * @notice This function can only be called by a contract with `SUPPLIER_CONTRACT_ROLE`
    */
    function mint(address account, uint256 _id, uint256 amount, string memory _newuri, bytes memory data) public onlyRole(SUPPLIER_CONTRACT_ROLE) {
        _mint(account, _id, amount, data);
        _setURI(_id,_newuri);
        emit Mint(_id, amount, account);
    }

    /**
    * @dev Transfers ownership of an NFT token from one address to another.
    * @param from - The current owner of the NFT.
    * @param to - The address to transfer the ownership to.
    * @param id - The ID of the NFT token.
    * @param data - Additional data to include in the transfer.
    * @notice This function is to disable the transfer functionality of the utility tokens
    */
    function _safeTransferFrom( address from, address to, uint256 id, uint256 amount, bytes memory data ) internal virtual override {
        revert NonTransferable("Token transfer not allowed.");
    }    

    /**
    * @dev Transfers ownership of multiple NFT tokens from one address to another.
    * @param from - The current owner of the NFTs.
    * @param to - The address to transfer the ownership to.
    * @param ids - The IDs of the NFT tokens.
    * @param data - Additional data to include in the transfer.
    * @notice This function is to disable the batch transfer functionality of the utility tokens
    */
    function _safeBatchTransferFrom( address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data ) internal virtual override {
        revert NonTransferable("Token transfer not allowed.");
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view override(AccessControl, ERC1155) returns (bool) {
        return super.supportsInterface(interfaceId);
    } 

    function _setURI(uint256 id, string memory newuri) internal {
        bookingTickets[id] = newuri;
    }
}
