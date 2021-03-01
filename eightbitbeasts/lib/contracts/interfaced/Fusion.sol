// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "./Owner.sol";

interface MotherInterface {
    struct Stats {
        uint16 hp;
        uint16 attackSpeed;
        uint16 evasion;
        uint16 primaryDamage;
        uint16 secondaryDamage;
        uint16 resistance;
        uint16 accuracy;
        uint16 constitution;
        uint16 intelligence;
    }

    function createBeast(
        string calldata _name,
        Stats memory _stats,
        uint256 _level,
        uint256 _xp,
        uint256 _readyTime,
        uint256 _winCount,
        uint256 _lossCount,
        uint256 _grade,
        uint256 _extractionsRemaining,
        uint8[22] memory _dna,
        address _address
    ) external;

    function getTamerBeastCount(address _tamer) external view returns (uint256);

    function dnaExists(uint8[22] memory _dna) external view returns (bool);
}

contract Fusion is Owner {
    struct Extract {
        address owner;
        uint256 beastId;
        uint32 expiry;
    }

    mapping(uint256 => Extract) extractToTamer;
}
