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

    address MotherAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    MotherInterface MotherContract = MotherInterface(MotherAddress);

    //internal helper functions
    function _checkUniqueDna(uint8[22] memory _dna)
        internal
        view
        returns (bool)
    {
        if (MotherContract.dnaExists(_dna)) {
            return false;
        } else {
            return true;
        }
    }

    function _cleanDna(uint8[22] memory _dna)
        internal
        pure
        returns (uint8[22] memory)
    {
        for (uint256 x = 2; x < 22; x = x + 2) {
            if (_dna[x] > _dna[x + 1]) {
                uint8 temp = _dna[x];
                _dna[x] = _dna[x + 1];
                _dna[x + 1] = temp;
            }
        }
        return _dna;
    }

    function _gradeFromDna(uint8[22] memory _dna)
        internal
        pure
        returns (uint8)
    {
        uint32 total = 0;
        for (uint256 x = 2; x < 22; x++) {
            total = total + _dna[x];
        }
        uint16 avg = uint8(total / 20);
        if (100 * avg >= 525) {
            if (avg >= 6) {
                if (avg * 10 >= 65) {
                    if (avg >= 7) {
                        if (10 * avg >= 75) {
                            return uint8(1);
                        } else {
                            return uint8(2);
                        }
                    } else {
                        return uint8(3);
                    }
                } else {
                    return uint8(4);
                }
            } else {
                if (100 * avg >= 575) {
                    return uint8(5);
                } else {
                    if (avg * 10 >= 55) {
                        return uint8(6);
                    } else {
                        return uint8(7);
                    }
                }
            }
        } else {
            if (avg >= 4) {
                if (avg >= 5) {
                    return uint8(8);
                } else {
                    return uint8(9);
                }
            } else {
                return uint8(10);
            }
        }
    }

    function _calculateStats(
        uint256 _id1,
        uint256 _id2,
        uint256 _type
    ) internal view returns (Stats memory) {
        //normal calculation
        if (_type == 1) {
            Stats memory newStats =
                Stats(
                    _weightedAvg(beasts[_id1].stats.hp, beasts[_id2].stats.hp),
                    _weightedAvg(
                        beasts[_id1].stats.attackSpeed,
                        beasts[_id2].stats.attackSpeed
                    ),
                    _weightedAvg(
                        beasts[_id1].stats.evasion,
                        beasts[_id2].stats.evasion
                    ),
                    _weightedAvg(
                        beasts[_id1].stats.primaryDamage,
                        beasts[_id2].stats.primaryDamage
                    ),
                    _weightedAvg(
                        beasts[_id1].stats.secondaryDamage,
                        beasts[_id2].stats.secondaryDamage
                    ),
                    _weightedAvg(
                        beasts[_id1].stats.resistance,
                        beasts[_id2].stats.resistance
                    ),
                    _weightedAvg(
                        beasts[_id1].stats.accuracy,
                        beasts[_id2].stats.accuracy
                    ),
                    _weightedAvg(
                        beasts[_id1].stats.constitution,
                        beasts[_id2].stats.constitution
                    ),
                    _weightedAvg(
                        beasts[_id1].stats.intelligence,
                        beasts[_id2].stats.intelligence
                    )
                );
            return newStats;
        }
        //slimes calculation
        if (_type == 2) {
            Stats memory newStats =
                Stats(
                    beasts[_id1].stats.hp.add(beasts[_id2].stats.hp),
                    beasts[_id1].stats.attackSpeed.add(
                        beasts[_id2].stats.attackSpeed
                    ),
                    beasts[_id1].stats.evasion.add(beasts[_id2].stats.evasion),
                    beasts[_id1].stats.primaryDamage.add(
                        beasts[_id2].stats.primaryDamage
                    ),
                    beasts[_id1].stats.secondaryDamage.add(
                        beasts[_id2].stats.secondaryDamage
                    ),
                    beasts[_id1].stats.resistance.add(
                        beasts[_id2].stats.resistance
                    ),
                    beasts[_id1].stats.accuracy.add(
                        beasts[_id2].stats.accuracy
                    ),
                    beasts[_id1].stats.constitution.add(
                        beasts[_id2].stats.constitution
                    ),
                    beasts[_id1].stats.intelligence.add(
                        beasts[_id2].stats.intelligence
                    )
                );
            return newStats;
        }
        revert("wrong type given to _calculateStats()");
    }

    //weighted to primary, which is the base/ one the player definitely owns(and probably weaker)
    function _weightedAvg(uint16 a, uint16 b) internal pure returns (uint16) {
        uint256 result = 2 * uint256(a);
        result = (result + b) / 3;
        return uint16(result);
    }

    function _calculateSpecies(
        uint256 _primaryId,
        uint256 _secondaryId,
        uint256 _type
    ) internal view returns (uint8[2] memory) {
        uint8[2] memory result;
        //normal 2 beasts calc
        //if primary ab and secondary cd, result is a then the lowest out of c and d
        if (_type == 1) {
            result[0] = beasts[_primaryId].dna[0];
            if (beasts[_secondaryId].dna[0] < beasts[_secondaryId].dna[1]) {
                result[1] = beasts[_secondaryId].dna[0];
            } else {
                result[1] = beasts[_secondaryId].dna[1];
            }
            return result;
        }
        //slime primary calc
        //always returns 00
        if (_type == 2) {
            result[0] = 0;
            result[0] = 0;
            return result;
        }
        //if slime secondary calc
        //always returns 0, # where # is primary primary species
        if (_type == 3) {
            result[0] = 0;
            result[1] = beasts[_primaryId].dna[0];
            return result;
        }
        //if both slimes calc
        if (_type == 4) {
            //if primary slime = 00, then result is random
            if (
                beasts[_primaryId].dna[0] == 0 && beasts[_primaryId].dna[1] == 0
            ) {
                uint256 rand =
                    uint256(keccak256(abi.encodePacked(block.timestamp))) % 10;
                result[0] = uint8(rand);
                result[1] = uint8(rand);
                return result;
            }
            //elif primary is 0a, and secondary is 0b, result is ab
            result[0] = beasts[_primaryId].dna[1];
            result[1] = beasts[_secondaryId].dna[1];
            return result;
        }
        revert("Wrong Type given to _calculateSpecies()");
    }

    function _calculateDna(uint256 _id1, uint256 _id2)
        internal
        view
        returns (uint8[22] memory)
    {
        uint8[51] memory p =
            _generateDigits(
                uint256(keccak256(abi.encodePacked(block.timestamp)))
            );
        uint8[22] memory dna;
        for (uint256 i = 2; i < 22; i = i + 2) {
            //each loop makes one gene
            //two alleles form a gene
            //weighted to take less rare, dominant allele
            //probability check for allele 1 (from id1)
            if (p[i] > 6) {
                //from id1, take recessive allele
                dna[i] = beasts[_id1].dna[i + 1];
                //else take dominant allele
            } else {
                dna[i] = beasts[_id1].dna[i];
            }

            //probability check for allele 2 (from id2)
            if (p[i + 1] > 6) {
                //from id2, take recessive allele
                dna[i + 1] = beasts[_id2].dna[i + 1];
                //else take dominant allele
            } else {
                dna[i + 1] = beasts[_id2].dna[i];
            }
        }
        //clean dna, reorder to form dom/rec allele structure
        dna = _cleanDna(dna);
        return dna;
    }

    //#######
    //main functions

    //between beasts, neither are slime
    function _beastFusion(
        uint256 _primaryId,
        uint256 _secondaryId,
        string memory _name
    ) internal returns (bool) {
        //create new data
        MotherInterface.Stats memory newStats =
            _calculateStats(_primaryId, _secondaryId, 1);
        uint8[22] memory newDna = _calculateDna(_primaryId, _secondaryId);
        uint8[2] memory newSpecies =
            _calculateSpecies(_primaryId, _secondaryId, 1);
        newDna[0] = newSpecies[0];
        newDna[1] = newSpecies[1];
        //Check dna
        uint256 attempts = 1;
        bool passing = _checkUniqueDna(newDna);
        while (passing != true) {
            uint256 index = (2 * attempts++ + 1) % 22;
            if (newDna[index] != 9) {
                newDna[index]++;
                passing = _checkUniqueDna(newDna);
            }
            if (attempts > 100) {
                return false;
            }
        }
        _initialiseBeast(_name, newDna, newStats, _gradeFromDna(newDna));
        return true;
    }
}
