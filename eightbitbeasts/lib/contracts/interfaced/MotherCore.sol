// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "./Owner.sol";

contract MotherCore is Owner {
    //contract concerning ownership of beasts, creation of beasts and fusion of beasts

    //values
    uint256 minRecoveryPeriod = 1 days;

    //Events

    event NewBeast(uint256 beastId, string name, uint256[22] dna);
    event LvlUp(uint256 beastId, string name, uint32 lvl);
    event NewTamer(uint256 tamerId, address tamerAddress);
    event StatBoost(uint256 beastId, string name, Stats stats);

    //structs

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

    struct Dna {
        uint8 speciesPrimary;
        uint8 speciesSecondary;
        uint8 primaryColorDom;
        uint8 primaryColorRec;
        uint8 secondaryColorDom;
        uint8 secondaryColorRec;
        uint8 bodyDom;
        uint8 bodyRec;
        uint8 headDom;
        uint8 headRec;
        uint8 tailDom;
        uint8 tailRec;
        uint8 limbsDom;
        uint8 limbsRec;
        uint8 wingsDom;
        uint8 wingsRec;
        uint8 mouthDom;
        uint8 mouthRec;
        uint8 eyesDom;
        uint8 extraRec;
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

    //storage
    Beast[] public beasts;

    mapping(address => bool) trustedAddresses;

    mapping(uint256 => address) public beastToTamer;
    mapping(address => uint256) tamerBeastCount;
    mapping(bytes32 => bool) hashedDnaExists;
    //currency
    mapping(address => uint256[2]) currency;

    //modifiers
    modifier isTrusted(address _address) {
        require(
            trustedAddresses[_address] == true,
            "Request is not from a trusted source"
        );
        _;
    }

    function addTrusted(address _address) external isOwner() {
        trustedAddresses[_address] = true;
    }

    //functions below will control beast generation and fusion, all internal. user facing functions will be in child contracts

    //############
    //Initialisation
    //############

    //core function to add beast to beasts
    function _initialiseBeast(
        string memory _name,
        Stats memory _stats,
        uint32 _level,
        uint32 _xp,
        uint32 _readyTime,
        uint16 _winCount,
        uint16 _lossCount,
        uint8 _grade,
        uint8 _extractionsRemaining,
        uint8[22] memory _dna,
        address _tamer
    ) internal isTrusted() {
        uint256 id = beasts.length;
        beasts.push(
            Beast(
                _name,
                _stats,
                uint128(id),
                _level,
                _xp,
                _readyTime,
                _winCount,
                _lossCount,
                _grade,
                _extractionsRemaining,
                _dna
            )
        );
        beastToTamer[id] = _tamer;
        tamerBeastCount[_tamer] += 1;
        hashedDnaExists[keccak256(abi.encodePacked(_dna))] = true;
        emit NewBeast(id, _name, _dna);
    }

    //############
    //ownership
    //############
}
