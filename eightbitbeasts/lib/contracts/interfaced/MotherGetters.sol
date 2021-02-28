// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "./MotherCore.sol";

contract MotherGetter is MotherCore {
    //getter functions

    function howManyBeasts() external view returns (uint256) {
        return beasts.length;
    }

    function getBeasts() external view returns (Beast[] memory) {
        return beasts;
    }

    function getBeast(int256 _beastId) external view returns (Beast memory) {
        return beasts(_beastId);
    }

    function getCurrency() external returns (uint256[2] memory) {
        return currency[msg.sender];
    }
}
