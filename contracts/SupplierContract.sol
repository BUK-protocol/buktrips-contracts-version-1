// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./ISupplierContractUtility.sol";

/**
* @title Supplier Contract
* @author BukTrips Technologies
* @dev Contract for managing supplier data and ERC1155 token management for active tickets
*/
contract SupplierContract is AccessControl, ERC1155 {

    /**
    * @dev address of the supplier contract
    */
    address internal utility_contract;
    /**
    * @dev Contract URI string
    */
    string internal contract_uri;
    /**
    * @dev address of the factory contract
    */
    address internal factory_contract;

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
    * @dev Mapping for token transferability status
    */
    mapping(uint256 => bool) public transferable; //tokenID -> uri

    /**
    * @dev Constant for the role of the supplier owner
    */
    bytes32 public constant SUPPLIER_OWNER_ROLE = keccak256("SUPPLIER_OWNER");
    /**
    * @dev Constant for the role of the factory contract
    */
    bytes32 public constant FACTORY_CONTRACT_ROLE = keccak256("FACTORY_CONTRACT");
    /**
    * @dev Constant for the role of both factory and supplier to update the contract
    */
    bytes32 public constant UPDATE_CONTRACT_ROLE = keccak256("UPDATE_CONTRACT_ROLE"); // Both Factory and Supplier


    /**
    * @dev Event to set the contract URI
    */
    event SetContractURI(string indexed contract_uri);
    /**
    * @dev Event to update the supplier details
    */
    event UpdateSupplierDetails(string indexed name);
    /**
    * @dev Event to set token URI
    */
    event SetURI(uint256 indexed id, string indexed uri);
    /**
    * @dev Event to toggle NFT status
    */
    event ToggleNFT(uint256 indexed _id, bool indexed status);
    /**
    * @dev Event to toggle NFT status
    */
    event BurnNFT( address indexed account, uint256 indexed amount, uint256 indexed _id);
    /**
    * @dev Event to mint NFT
    */
    event Mint(uint256 indexed id, uint256 indexed amount, address indexed to);
    /**
    * @dev Event to safe transfer NFT
    */
    event SafeTransfer(address indexed from, address indexed to, uint256 indexed id);

    /**
    * @dev Constructor to initialize the contract
    * @param _id Supplier ID
    * @param _name Supplier name
    * @param _supplier_owner Address of the supplier owner
    * @param _utility_contract Address of the utility contract
    * @param _factory_contract Address of the factory contract
    * @param _contract_uri Contract URI string
    */
    constructor(uint256 _id, string memory _name, address _supplier_owner, address _utility_contract, address _factory_contract, string memory _contract_uri) ERC1155("") {
        Details.id = _id;
        Details.name = _name;
        _grantRole(SUPPLIER_OWNER_ROLE, _supplier_owner);
        _grantRole(FACTORY_CONTRACT_ROLE, _factory_contract);
        _grantRole(UPDATE_CONTRACT_ROLE, _supplier_owner);
        _grantRole(UPDATE_CONTRACT_ROLE, _factory_contract);
        factory_contract = _factory_contract;
        utility_contract = _utility_contract;
        contract_uri = _contract_uri;
    }


    /**
    * @dev Returns the id and name of the supplier.
    * @return id - ID of the supplier.
    * @return name - Name of the supplier.
    */
    function getSupplierDetails() external view returns (uint256 id, string memory name) {
        return (Details.id, Details.name);
    }

    /**
    * @dev Set the contract URI of the supplier contract.
    * @param _contract_uri - The URI to be set.
    * @notice This function can only be called by a contract with `FACTORY_CONTRACT_ROLE`
    */
    function setContractURI(string memory _contract_uri) external onlyRole(FACTORY_CONTRACT_ROLE) {
        contract_uri = _contract_uri;
        ISupplierContractUtility(utility_contract).setContractURI(_contract_uri);
        emit SetContractURI(contract_uri);
    }
    
    /**
    * @dev Returns the contract URI of the supplier contract.
    * @return contract_uri - The URI of the supplier contract.
    */
    function contractURI() external view returns (string memory) {
        return contract_uri;
    }

    /**
    * @dev Update the details of the supplier.
    * @param _name - The new name of the supplier.
    * @notice This function can only be called by addresses with `UPDATE_CONTRACT_ROLE`
    */
    function updateSupplierDetails(string memory _name) external onlyRole(UPDATE_CONTRACT_ROLE) {
        Details.name = _name;
        ISupplierContractUtility(utility_contract).updateSupplierDetails(_name);
        emit UpdateSupplierDetails(_name);
    }

    /**
    * @dev Returns the URI associated with the token ID.
    * @param _id - The token ID to retrieve the URI for.
    * @return string - The URI associated with the token ID.
    */
    function uri(uint256 _id) public view virtual override returns (string memory) {
        return bookingTickets[_id];
    }

    /**
    * @dev Sets the URI for a specific token ID.
    * @param _id - The ID of the token.
    * @param _newuri - The new URI for the token.
    * @notice This function can only be called by a contract with `FACTORY_CONTRACT_ROLE`
    */
    function setURI(uint256 _id, string memory _newuri) external onlyRole(FACTORY_CONTRACT_ROLE) {
        _setURI(_id,_newuri);
        emit SetURI(_id,_newuri);
    }

    /**
    * @dev Toggle the transferable status of the NFT.
    * @param _id - The token ID to toggle the transferable status for.
    * @param _status - The new transferable status for the NFT.
    */
    function toggleNFTStatus(uint256 _id, bool _status) external onlyRole(FACTORY_CONTRACT_ROLE) {
        transferable[_id] = _status;
        emit ToggleNFT(_id,_status);
    }

    /**
    * @dev Mint a new NFT with a specific token ID, account, amount, and data.
    * @param _id - The token ID to mint the NFT with.
    * @param account - The account to mint the NFT to.
    * @param amount - The amount of NFTs to mint.
    * @param data - The data to store with the NFT.
    * @param _uri - The URI to associate with the NFT.
    * @param _status - The transferable status for the NFT.
    * @return uint256 - The token ID of the newly minted NFT.
    * @notice This function can only be called by a contract with `FACTORY_CONTRACT_ROLE`
    */
    function mint(uint256 _id, address account, uint256 amount, bytes memory data, string memory _uri, bool _status) external onlyRole(FACTORY_CONTRACT_ROLE) returns (uint256) {
        transferable[_id] = _status;
        _mint(account, _id, amount, data);
        _setURI( _id, _uri);
        emit Mint(_id, amount, account);
        return ( _id );
    }

    /**
    * @dev Burn a specific NFT.
    * @param account - The account to burn the NFT from.
    * @param id - The token ID of the NFT to burn.
    * @param amount - The amount of NFTs to burn.
    * @param utility - Whether or not to call the utility contract to burn the NFT.
    * @notice This function can only be called by a contract with `FACTORY_CONTRACT_ROLE`
    */
    function burn(address account, uint256 id, uint256 amount, bool utility) external onlyRole(FACTORY_CONTRACT_ROLE) {
        string memory uri_ =  bookingTickets[id];
        bookingTickets[id] = "";
        if(utility) {
            ISupplierContractUtility(utility_contract).mint(account, id, amount, uri_, "");
        }
        _burn(account, id, amount);
        emit BurnNFT(account, id, amount);
    }

    /**
    * @dev Transfers ownership of an NFT token from one address to another.
    * @param from - The current owner of the NFT.
    * @param to - The address to transfer the ownership to.
    * @param id - The ID of the NFT token.
    * @param data - Additional data to include in the transfer.
    */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) public virtual override {
        require(transferable[id], "This NFT is non transferable");
        require(from == _msgSender() || isApprovedForAll(from, _msgSender()), "ERC1155: caller is not token owner or approved");
        _safeTransferFrom(from, to, id, amount, data);
        emit SafeTransfer(from, to, id);
    }

    /**
    * @dev Transfers ownership of multiple NFT tokens from one address to another.
    * @param from - The current owner of the NFTs.
    * @param to - The address to transfer the ownership to.
    * @param ids - The IDs of the NFT tokens.
    * @param data - Additional data to include in the transfer.
    */
    function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public virtual override {
        require((ids.length < 11), "Exceeds max room booking limit");
        uint256 len = ids.length;
        for(uint i=0; i<len; ++i) {
            require(transferable[ids[i]], "One of these NFT is non-transferable");
        }
        require(from == _msgSender() || isApprovedForAll(from, _msgSender()), "ERC1155: caller is not token owner or approved");
        _safeBatchTransferFrom(from, to, ids, amounts, data);
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
