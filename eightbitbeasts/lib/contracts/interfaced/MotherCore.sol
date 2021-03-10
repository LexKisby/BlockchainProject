// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "./Owner.sol";

contract MotherCore is Owner {
    //contract concerning ownership of beasts, creation of beasts and fusion of beasts

    //values
    uint256 minRecoveryPeriod = 1 days;
    int256 levelUpPrice = 100; //rubies
    uint256 levelUpXp = 100; //xp
    uint256 etherFee = 0.001 ether;

    //Events

    event NewBeast(uint256 beastId, string name, uint8[22] dna);
    event LvlUp(uint256 beastId, string name, uint32 lvl);
    event NewTamer(uint256 tamerId, address tamerAddress);
    event StatBoost(uint256 beastId, string name, Stats stats);
    event NameChange(uint256 beastId, string newName);
    event ContractUpdate(string aspect, uint256 newValue);
    event BeastTransfer(uint256 beastId, address from, address to);

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

    //Not used, exists only for reference
    /**
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
    }*/

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

    mapping(uint256 => address) public beastToTamer;
    mapping(address => uint256) public tamerBeastCount;
    mapping(bytes32 => bool) hashedDnaExists;
    //currency
    mapping(address => int256[2]) public currency;

    //modifiers

    modifier beastOwner(uint256 _beastId) {
        require(
            msg.sender == beastToTamer[_beastId],
            "You do not own this beast"
        );
        _;
    }

    function withdraw() external isOwner() {
        address _owner = _getOwner();
        address payable owner = payable(_owner);
        owner.transfer(address(this).balance);
    }

    function checkBalance() external view isOwner() returns (uint256) {
        return address(this).balance;
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

    function _checkUniqueDna(uint8[22] memory _dna)
        internal
        view
        returns (bool)
    {
        if (hashedDnaExists[keccak256(abi.encodePacked(_dna))]) {
            return false;
        } else {
            return true;
        }
    }
}
