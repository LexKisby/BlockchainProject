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

    function getBeast(uint256 _beastId) external view returns (Beast memory);

    function isTamer(uint256 _beastId, address _tamer)
        external
        view
        returns (bool);

    function reduceExtractions(uint256 _beastId) external;

    function triggerRecoveryPeriod(uint256 _beastId, uint32 _factor) external;
}

contract Fusion is Owner {
    struct Extract {
        address owner;
        uint256 beastId;
        uint32 expiry;
    }

    mapping(uint256 => Extract) extractToTamer;

    uint256 minRecoveryPeriod = 1 days;

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

    function _generateDigits(uint256 _num)
        internal
        pure
        returns (uint8[51] memory)
    {
        uint8[51] memory digits;
        for (uint256 x = 0; x < 51; x++) {
            uint8 digit = uint8(_num % 10);
            _num = _num / 10;
            digits[x] = digit;
        }
        return digits;
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
        MotherInterface.Beast memory _id1,
        MotherInterface.Beast memory _id2,
        uint256 _type
    ) internal pure returns (MotherInterface.Stats memory) {
        //normal calculation
        if (_type == 1) {
            MotherInterface.Stats memory newStats =
                MotherInterface.Stats(
                    _weightedAvg(_id1.stats.hp, _id2.stats.hp),
                    _weightedAvg(
                        _id1.stats.attackSpeed,
                        _id2.stats.attackSpeed
                    ),
                    _weightedAvg(_id1.stats.evasion, _id2.stats.evasion),
                    _weightedAvg(
                        _id1.stats.primaryDamage,
                        _id2.stats.primaryDamage
                    ),
                    _weightedAvg(
                        _id1.stats.secondaryDamage,
                        _id2.stats.secondaryDamage
                    ),
                    _weightedAvg(_id1.stats.resistance, _id2.stats.resistance),
                    _weightedAvg(_id1.stats.accuracy, _id2.stats.accuracy),
                    _weightedAvg(
                        _id1.stats.constitution,
                        _id2.stats.constitution
                    ),
                    _weightedAvg(
                        _id1.stats.intelligence,
                        _id2.stats.intelligence
                    )
                );
            return newStats;
        }
        //slimes calculation
        if (_type == 2) {
            MotherInterface.Stats memory newStats =
                MotherInterface.Stats(
                    _id1.stats.hp + _id2.stats.hp,
                    _id1.stats.attackSpeed + _id2.stats.attackSpeed,
                    _id1.stats.evasion + _id2.stats.evasion,
                    _id1.stats.primaryDamage + _id2.stats.primaryDamage,
                    _id1.stats.secondaryDamage + _id2.stats.secondaryDamage,
                    _id1.stats.resistance + _id2.stats.resistance,
                    _id1.stats.accuracy + _id2.stats.accuracy,
                    _id1.stats.constitution + _id2.stats.constitution,
                    _id1.stats.intelligence + _id2.stats.intelligence
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
        MotherInterface.Beast memory _primaryBeast,
        MotherInterface.Beast memory _secondaryBeast,
        uint256 _type
    ) internal view returns (uint8[2] memory) {
        uint8[2] memory result;
        //normal 2 beasts calc
        //if primary ab and secondary cd, result is a then the lowest out of c and d
        if (_type == 1) {
            result[0] = _primaryBeast.dna[0];
            if (_secondaryBeast.dna[0] < _secondaryBeast.dna[1]) {
                result[1] = _secondaryBeast.dna[0];
            } else {
                result[1] = _secondaryBeast.dna[1];
            }
            return result;
        }
        //slime primary calc
        //always returns 00
        if (_type == 2) {
            result[0] = 0;
            result[1] = 0;
            return result;
        }
        //if slime secondary calc
        //always returns 0#, where # is primary primary species
        if (_type == 3) {
            result[0] = 0;
            result[1] = _primaryBeast.dna[0];
            return result;
        }
        //if both slimes calc
        if (_type == 4) {
            //if primary slime = 00, then result is random
            if (_primaryBeast.dna[0] == 0 && _primaryBeast.dna[1] == 0) {
                uint256 rand =
                    uint256(keccak256(abi.encodePacked(block.timestamp))) % 10;
                result[0] = uint8(rand);
                result[1] = uint8(rand);
                return result;
            }
            //elif primary is 0a, and secondary is 0b, result is ab
            result[0] = _primaryBeast.dna[1];
            result[1] = _secondaryBeast.dna[1];
            return result;
        }
        revert("Wrong Type given to _calculateSpecies()");
    }

    function _calculateDna(
        MotherInterface.Beast memory _id1,
        MotherInterface.Beast memory _id2
    ) internal view returns (uint8[22] memory) {
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
                dna[i] = _id1.dna[i + 1];
                //else take dominant allele
            } else {
                dna[i] = _id1.dna[i];
            }

            //probability check for allele 2 (from id2)
            if (p[i + 1] > 6) {
                //from id2, take recessive allele
                dna[i + 1] = _id2.dna[i + 1];
                //else take dominant allele
            } else {
                dna[i + 1] = _id2.dna[i];
            }
        }
        //clean dna, reorder to form dom/rec allele structure
        dna = _cleanDna(dna);
        return dna;
    }

    function _extractionsFromDna(uint8[22] memory _dna)
        internal
        pure
        returns (uint8)
    {
        if (_dna[0] == 0) {
            return 1;
        }
        return 10;
    }

    //#######
    //main functions

    //between beasts, neither are slime
    function _beastFusion(
        MotherInterface.Beast memory _primaryBeast,
        MotherInterface.Beast memory _secondaryBeast,
        string memory _name
    ) internal returns (bool) {
        //create new data
        MotherInterface.Stats memory newStats =
            _calculateStats(_primaryBeast, _secondaryBeast, 1);
        uint8[22] memory newDna = _calculateDna(_primaryBeast, _secondaryBeast);
        uint8[2] memory newSpecies =
            _calculateSpecies(_primaryBeast, _secondaryBeast, 1);
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
        uint8 grade = _gradeFromDna(newDna);
        MotherContract.createBeast(
            _name,
            newStats,
            1,
            0,
            uint32(block.timestamp + (11 - grade) * minRecoveryPeriod),
            0,
            0,
            grade,
            _extractionsFromDna(newDna),
            newDna,
            msg.sender
        );
        return true;
    }

    //fusion of two slimes
    function _slimeFusion(
        MotherInterface.Beast memory _primaryBeast,
        MotherInterface.Beast memory _secondaryBeast,
        string memory _name
    ) internal returns (bool) {
        //create new data
        MotherInterface.Stats memory newStats =
            _calculateStats(_primaryBeast, _secondaryBeast, 2);
        uint8[22] memory newDna = _calculateDna(_primaryBeast, _secondaryBeast);
        uint8[2] memory newSpecies =
            _calculateSpecies(_primaryBeast, _secondaryBeast, 4);
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
        uint8 grade = _gradeFromDna(newDna);
        MotherContract.createBeast(
            _name,
            newStats,
            1,
            0,
            uint32(block.timestamp + (11 - grade) * minRecoveryPeriod),
            0,
            0,
            grade,
            _extractionsFromDna(newDna),
            newDna,
            msg.sender
        );
        return true;
    }

    function _slimePrimaryFusion(
        MotherInterface.Beast memory _primaryBeast,
        MotherInterface.Beast memory _secondaryBeast,
        string memory _name
    ) internal returns (bool) {
        //create new data
        MotherInterface.Stats memory newStats =
            _calculateStats(_primaryBeast, _secondaryBeast, 1);
        uint8[22] memory newDna = _calculateDna(_primaryBeast, _secondaryBeast);
        uint8[2] memory newSpecies =
            _calculateSpecies(_primaryBeast, _secondaryBeast, 2);
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
        uint8 grade = _gradeFromDna(newDna);
        MotherContract.createBeast(
            _name,
            newStats,
            1,
            0,
            uint32(block.timestamp + (11 - grade) * minRecoveryPeriod),
            0,
            0,
            grade,
            _extractionsFromDna(newDna),
            newDna,
            msg.sender
        );
        return true;
    }

    function _slimeSecondaryFusion(
        MotherInterface.Beast memory _primaryBeast,
        MotherInterface.Beast memory _secondaryBeast,
        string memory _name
    ) internal returns (bool) {
        //create new data
        MotherInterface.Stats memory newStats =
            _calculateStats(_primaryBeast, _secondaryBeast, 1);
        uint8[22] memory newDna = _calculateDna(_primaryBeast, _secondaryBeast);
        uint8[2] memory newSpecies =
            _calculateSpecies(_primaryBeast, _secondaryBeast, 3);
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
        uint8 grade = _gradeFromDna(newDna);
        MotherContract.createBeast(
            _name,
            newStats,
            1,
            0,
            uint32(block.timestamp + (11 - grade) * minRecoveryPeriod),
            0,
            0,
            grade,
            _extractionsFromDna(newDna),
            newDna,
            msg.sender
        );
        return true;
    }

    //#####
    //external switch function that is called to determine type of fusion
    //#####

    function BeastFusionSwitch(
        uint256 _primaryId,
        uint256 _secondaryId,
        string calldata _name
    ) external returns (bool) {
        //check authorised for primary beast
        require(
            MotherContract.isTamer(_primaryId, msg.sender),
            "You do not own this beast"
        );
        //bring beasts into memory
        MotherInterface.Beast memory primaryBeast =
            MotherContract.getBeast(_primaryId);
        MotherInterface.Beast memory secondaryBeast =
            MotherContract.getBeast(_secondaryId);
        //check if owns secondary
        bool ownsSecondary = MotherContract.isTamer(_secondaryId, msg.sender);
        bool ownsExtract;
        //if we own the secondary, continue
        if (ownsSecondary != true) {
            ownsExtract = (extractToTamer[_secondaryId].owner == msg.sender &&
                extractToTamer[_secondaryId].expiry > block.timestamp);
            if (ownsExtract != true) {
                revert("you cannot use this secondary beast");
            }
        }
        //check beasts have available extractions and are ready
        if (primaryBeast.extractionsRemaining == 0) {
            revert("primary beast has no more extractions");
        }
        if (primaryBeast.readyTime > block.timestamp) {
            revert("primary beast not ready");
        }
        MotherContract.reduceExtractions(_primaryId);
        if (ownsSecondary) {
            if (secondaryBeast.extractionsRemaining == 0) {
                revert("secondary beast has no more extractions");
            }
            if (secondaryBeast.readyTime > block.timestamp) {
                revert("secondary beast is not ready");
            }
            MotherContract.reduceExtractions(_secondaryId);
        }

        //check for type of fusion
        bool isPrimarySlime = primaryBeast.dna[0] == 0;
        bool isSecondarySlime = secondaryBeast.dna[0] == 0;
        bool success;
        // both are slime #############################################
        if (isPrimarySlime && isSecondarySlime) {
            success = _slimeFusion(primaryBeast, secondaryBeast, _name);
            return success;
        }
        // Primary is slime #############################################
        if (isPrimarySlime) {
            success = _slimePrimaryFusion(primaryBeast, secondaryBeast, _name);
        }
        // secondary is slime ###########################################
        if (isSecondarySlime) {
            success = _slimeSecondaryFusion(
                primaryBeast,
                secondaryBeast,
                _name
            );
        }
        //neither are slime ##############################################
        else {
            success = _beastFusion(primaryBeast, secondaryBeast, _name);
        }
        //put monsters into recovery
        if (ownsSecondary) {
            MotherContract.triggerRecoveryPeriod(_secondaryId, 1);
        }
        MotherContract.triggerRecoveryPeriod(_primaryId, 2);
        //remove disposable extract by setting to 0 address
        if (ownsExtract) {
            extractToTamer[_secondaryId].owner = address(0);
        }
        return success;
    }
}
