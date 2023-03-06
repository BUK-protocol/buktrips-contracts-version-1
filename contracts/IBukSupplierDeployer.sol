// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IBukSupplierDeployer {
    function deploySupplier(uint256 id, string memory _name, address _supplier_owner, address _utility_contract_addr, string memory _contract_uri) external returns (address);
}
