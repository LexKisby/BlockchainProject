// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "./BeastFusion.sol";

contract OwnerPrivileges is BeastFusion {
    function ownerCreateBeast(
        string calldata _name,
        uint8[22] calldata _dna,
        Stats calldata _stats,
        uint8 _grade
    ) external isOwner() {
        _initialiseBeast(_name, _dna, _stats, _grade);
    }
}
