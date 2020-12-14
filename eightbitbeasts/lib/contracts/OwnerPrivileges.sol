// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.8.0;

contract OwnerPrivileges is {
    function ownerCreateBeast(string memory _name, uint256 _dna, Stats _stats, uint8 _grade) isOwner() external {
        _initialiseBeast(_name, _dna, _stats, _grade);
}

