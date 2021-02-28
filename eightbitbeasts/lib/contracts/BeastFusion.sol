// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "./BeastGenerator.sol";
import "./SafeMath.sol";

contract BeastFusion is BeastGenerator {
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    struct Extract {
        address owner;
        uint256 beastId;
        uint32 expiry;
    }
    mapping(uint256 => Extract) extractToTamer;

    modifier onlyOwner(uint256 _beastId) {
        require(
            msg.sender == beastToTamer[_beastId],
            "You do not own this beast"
        );
        _;
    }

    //for existing beasts only
    function _triggerRecoveryPeriod(uint256 _beastId, uint32 _factor) internal {
        beasts[_beastId].readyTime = uint32(
            block.timestamp + _factor * minRecoveryPeriod
        );
    }

    function _isReady(uint256 _beastId) internal view returns (bool) {
        return (beasts[_beastId].readyTime <= block.timestamp);
    }

    function _isSlime(uint256 _beastId) internal view returns (bool) {
        return (beasts[_beastId].dna[0] == 0);
    }

    //######################################################################
    //main reproduction functions
    function _beastFusion(
        uint256 _primaryId,
        uint256 _secondaryId,
        string memory _name
    ) internal returns (bool) {
        //create new data
        Stats memory newStats = _calculateStats(_primaryId, _secondaryId, 1);
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

    function _slimeFusion(
        uint256 _primaryId,
        uint256 _secondaryId,
        string memory _name
    ) internal returns (bool) {
        //create new data
        Stats memory newStats = _calculateStats(_primaryId, _secondaryId, 2);
        uint8[22] memory newDna = _calculateDna(_primaryId, _secondaryId);
        uint8[2] memory newSpecies =
            _calculateSpecies(_primaryId, _secondaryId, 4);
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

    function _slimePrimaryFusion(
        uint256 _primaryId,
        uint256 _secondaryId,
        string memory _name
    ) internal returns (bool) {
        //create new data
        Stats memory newStats = _calculateStats(_primaryId, _secondaryId, 1);
        uint8[22] memory newDna = _calculateDna(_primaryId, _secondaryId);
        uint8[2] memory newSpecies =
            _calculateSpecies(_primaryId, _secondaryId, 2);
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

    function _slimeSecondaryFusion(
        uint256 _primaryId,
        uint256 _secondaryId,
        string memory _name
    ) internal returns (bool) {
        //create new data
        Stats memory newStats = _calculateStats(_primaryId, _secondaryId, 1);
        uint8[22] memory newDna = _calculateDna(_primaryId, _secondaryId);
        uint8[2] memory newSpecies =
            _calculateSpecies(_primaryId, _secondaryId, 3);
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

    //assister functions#####################################################
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

    //########################################################################
    //decider for which logic to use
    function BeastFusionSwitch(
        uint256 _primaryId,
        uint256 _secondaryId,
        string calldata _name
    ) external onlyOwner(_primaryId) returns (bool) {
        //check authorised for beasts
        bool ownsSecondary = (beastToTamer[_secondaryId] == msg.sender);
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
        if (beasts[_primaryId].extractionsRemaining == 0) {
            revert("primary beast has no more extractions");
        }
        if (_isReady(_primaryId) == false) {
            revert("primary beast not ready");
        }
        beasts[_primaryId].extractionsRemaining--;
        if (ownsSecondary) {
            if (beasts[_secondaryId].extractionsRemaining == 0) {
                revert("secondary beast has no more extractions");
            }
            if (_isReady(_secondaryId) == false) {
                revert("secondary beast is not ready");
            }
            beasts[_secondaryId].extractionsRemaining--;
        }

        //check for type of repro
        bool isPrimarySlime = _isSlime(_primaryId);
        bool isSecondarySlime = _isSlime(_secondaryId);
        bool success;
        // both are slime #############################################
        if (isPrimarySlime && isSecondarySlime) {
            success = _slimeFusion(_primaryId, _secondaryId, _name);
            return success;
        }
        // Primary is slime #############################################
        if (isPrimarySlime) {
            success = _slimePrimaryFusion(_primaryId, _secondaryId, _name);
        }
        // secondary is slime ###########################################
        if (isSecondarySlime) {
            success = _slimeSecondaryFusion(_primaryId, _secondaryId, _name);
        }
        //neither are slime ##############################################
        else {
            success = _beastFusion(_primaryId, _secondaryId, _name);
        }
        //put monsters into recovery
        if (ownsSecondary) {
            _triggerRecoveryPeriod(_secondaryId, 1);
        }
        _triggerRecoveryPeriod(_primaryId, 2);
        //remove disposable extract by setting to 0 address
        if (ownsExtract) {
            extractToTamer[_secondaryId].owner = address(0);
        }
        return success;
    }

    //#####################################################################
    //TEST FUNCTIONS
    //#####################################################################
    /*
    function createSpecies(uint8 n, string calldata _name, uint16 _grade) external {
        uint8[22] memory dna = _generateRandomDnaFromGrade(uint8(_grade));
        dna[0] = n;
        dna[1] = n;
        uint16 num = 50 * (11 - _grade);
        Stats memory stats = Stats(num, num, num, num, num, num, num, num, num);
        _initialiseBeast(_name, dna, stats, _gradeFromDna(dna));
    }*/
}
