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

    function getBeast(uint256 _beastId) external view returns (Beast memory) {
        return beasts[_beastId];
    }

    function getCurrency() external view returns (uint256[2] memory) {
        return currency[msg.sender];
    }

    function getBeastsByTamer(address _tamer)
        external
        view
        returns (Beast[] memory)
    {
        Beast[] memory result = new Beast[](tamerBeastCount[_tamer]);
        uint256 counter = 0;
        for (uint256 i = 0; i < beasts.length; i++) {
            if (beastToTamer[i] == _tamer) {
                result[counter] = beasts[i];
                counter++;
            }
        }
        return result;
    }

    function getTamerBeastCount(address _tamer)
        external
        view
        returns (uint256)
    {
        return tamerBeastCount[_tamer];
    }

    function dnaExists(uint8[22] memory _dna) external view returns (bool) {
        return _checkUniqueDna(_dna);
    }
}
