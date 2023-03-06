// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IBukSupplierUtilityDeployer {
    function deploySupplierUtility(uint256 id, string memory _name, string memory _contract_uri) external returns (address);
}
