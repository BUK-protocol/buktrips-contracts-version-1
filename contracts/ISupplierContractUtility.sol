// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface ISupplierContractUtility {

    function grantSupplierRole(address _hotel_contract) external;

    function setContractURI(string memory _contract_uri) external;

    function updateSupplierDetails(string memory name) external;

    function setURI(uint256 _id, string memory _newuri) external;

    function mint(address account, uint256 id, uint256 amount, string memory _newuri, bytes memory data) external;
}
