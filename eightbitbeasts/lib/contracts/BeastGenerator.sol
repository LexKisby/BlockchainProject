// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "./Owner.sol";
import "./SafeMath.sol";

contract BeastGenerator is Owner {
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    event NewBeast(uint256 beastId, string name, uint8[22] dna);

    uint256 minRecoveryPeriod = 1 days;

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
        uint8[22] dna;
    }

    Beast[] public beasts;

    mapping(uint256 => address) public beastToTamer;
    mapping(address => uint256) tamerBeastCount;
    mapping(bytes32 => bool) public hashedDnaExists;

    //Pass newly created beast to here to finalise
    function _initialiseBeast(
        string memory _name,
        uint8[22] memory _dna,
        Stats memory _stats,
        uint8 _grade
    ) internal {
        uint256 id = beasts.length;
        beasts.push(
            Beast(
                _name,
                _stats,
                uint128(id),
                1,
                0,
                uint32(block.timestamp + (11 - _grade) * minRecoveryPeriod),
                0,
                0,
                _grade,
                _dna
            )
        );
        beastToTamer[id] = msg.sender;
        tamerBeastCount[msg.sender] = tamerBeastCount[msg.sender].add(1);
        emit NewBeast(id, _name, _dna);
    }

    //given a grade, create dna string.
    function _generateRandomDnaFromGrade(uint8 _grade)
        internal
        view
        returns (uint8[22] memory)
    {
        uint256 rand = uint256(
            keccak256(abi.encodePacked(msg.sender, block.timestamp, _grade))
        );
        uint8[51] memory digits = _generateDigits(rand);
        uint8[22] memory rawDna;
        rawDna[0] = digits[0];
        rawDna[1] = digits[0];
        uint32 avgx100 = _getAvgX100FromGrade(_grade);
        uint32 count = avgx100 / 5 + 1;
        for (uint256 y = 0; y < count; y++) {
            uint256 x = y % 50;
            bool which;
            if (digits[x + 1] % 2 == 0) {
                which = true;
            } else {
                which = false;
            }
            uint256 index;
            if (which) {
                index = 2 * digits[x] + 2;
            } else {
                index = 2 * digits[x] + 3;
            }
            if (rawDna[index] != 9) {
                rawDna[index]++;
            }
        }
        uint16 attempts = 0;
        rawDna = _cleanDna(rawDna);
        bool passingUnique = _checkUniqueDna(rawDna);
        while (passingUnique != true) {
            uint8 index = 2 * digits[digits[attempts]] + 1;
            if (rawDna[index] != 9) {
                rawDna[index]++;
                attempts++;
                passingUnique = _checkUniqueDna(rawDna);
            }
        }
        return rawDna;
    }

    function _generateDigits(uint256 _num)
        internal
        pure
        returns (uint8[51] memory)
    {
        uint8[51] memory digits;
        for (uint256 x = 0; x < 51; x++) {
            uint8 digit = uint8(_num % 10);
            _num = _num.div(10);
            digits[x] = digit;
        }
        return digits;
    }

    function _checkDnaForGrade(uint8[22] memory _dna, uint8 _grade)
        internal
        pure
        returns (uint8, bool)
    {
        uint8 rawGrade = _gradeFromDna(_dna);
        if (_grade == rawGrade) {
            return (rawGrade, true);
        } else {
            return (rawGrade, false);
        }
    }

    function _gradeFromDna(uint8[22] memory _dna)
        internal
        pure
        returns (uint8)
    {
        uint32 total = 0;
        for (uint256 x = 2; x < 22; x++) {
            total = total.add(_dna[x]);
        }
        uint16 avg = uint8(total.div(20));
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

    function _cleanDna(uint8[22] memory _dna)
        internal
        pure
        returns (uint8[22] memory)
    {
        for (uint256 x = 2; x < 22; x = x.add(2)) {
            if (_dna[x] > _dna[x + 1]) {
                uint8 temp = _dna[x];
                _dna[x] = _dna[x + 1];
                _dna[x + 1] = temp;
            }
        }
        return _dna;
    }

    function _getAvgX100FromGrade(uint8 _grade) internal pure returns (uint32) {
        if (_grade == 10) {
            return 300;
        }
        if (_grade == 9) {
            return 400;
        }
        if (_grade == 8) {
            return 500;
        }
        if (_grade == 7) {
            return 525;
        }
        if (_grade == 6) {
            return 550;
        }
        if (_grade == 5) {
            return 575;
        }
        if (_grade == 4) {
            return 600;
        }
        if (_grade == 3) {
            return 650;
        }
        if (_grade == 2) {
            return 700;
        }
        if (_grade == 1) {
            return 750;
        }
        return 0;
    }

    function _generateRandomMonsterFromGrade(string memory _name, uint8 _grade)
        internal
    {
        uint8[22] memory dna = _generateRandomDnaFromGrade(_grade);
        uint16 num = 50 * (11 - _grade);
        Stats memory stats = Stats(num, num, num, num, num, num, num, num, num);
        _initialiseBeast(_name, dna, stats, _gradeFromDna(dna));
    }

    function generateStarterBeast(string memory _name) external {
        uint8[22] memory dna = _generateRandomDnaFromGrade(10);
        Stats memory stats = Stats(12, 2, 4, 3, 1, 0, 2, 1, 2);
        _initialiseBeast(_name, dna, stats, _gradeFromDna(dna));
    }

    //####################################################################################################################
    function getBeasts() external view returns (Beast[] memory) {
        return beasts;
    }

    function howManyBeasts() external view returns (uint256) {
        return beasts.length;
    }

    function testGenerateDnaFromGrade(uint8 _grade)
        external
        view
        returns (uint8[22] memory)
    {
        uint8[22] memory dna = _generateRandomDnaFromGrade(_grade);
        return dna;
    }

    function testAvg(uint8 num) external pure returns (uint32) {
        return _getAvgX100FromGrade(num);
    }

    function testCleanDna(uint8[22] calldata _dna)
        external
        pure
        returns (uint8[22] memory)
    {
        uint8[22] memory dna = _cleanDna(_dna);
        return dna;
    }

    function testGradeFromDna(uint8[22] calldata _dna, uint8 _grade)
        external
        pure
        returns (bool, uint8)
    {
        (uint8 grade, bool yes) = _checkDnaForGrade(_dna, _grade);
        return (yes, grade);
    }

    function testDigits(uint256 num) external pure returns (uint8[51] memory) {
        return _generateDigits(num);
    }

    function testUnique(uint8[22] calldata dna) external view returns (bool) {
        return _checkUniqueDna(dna);
    }
}
