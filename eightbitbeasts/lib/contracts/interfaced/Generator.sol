// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;

import "./Owner.sol";

contract MotherInterface {
    function createBeast(
        string calldata _name,
        Stats _stats,
        uint256 _level,
        uint256 _xp,
        uint256 _readyTime,
        uint256 _winCount,
        uint256 _lossCount,
        uint256 _grade,
        uint256 _extractionsRemaining,
        uint8[22] _dna,
        address _address
    ) external;

    function setStats(
        uint256 _beastId,
        uint256 _hp,
        uint256 _attackSpeed,
        uint256 _evasion,
        uint256 _primaryDamage,
        uint256 _secondaryDamage,
        uint256 _resistance,
        uint256 _accuracy,
        uint256 _constitution,
        uint256 _intelligence
    ) external;

    function depositRubies(int256 _quantity, address _address) external;

    function depositEssence(int256 _quantity, address _address) external;
}

contract Generator is Owner {
    //handles the generation of new monsters

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

    struct Beast {
        string name;
        Stats stats;
        uint256 id;
        uint32 level;
        uint32 xp;
        uint32 readyTime;
        uint16 winCount;
        uint16 lossCount;
        uint8 grade;
        uint8 extractionsRemaining;
        uint8[22] dna;
    }

    //needs changing
    address MotherAddress = 0x76f6e;
    MotherInterface MotherContract = MotherInterface(MotherAddress);

    //internal functions
}
