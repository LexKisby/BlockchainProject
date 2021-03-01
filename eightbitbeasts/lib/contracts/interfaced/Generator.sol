// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "./Owner.sol";

contract MotherInterface {
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

    function getTamerBeastCount(address _tamer) external view returns (uint256);
}

contract Generator is Owner {
    //handles the generation of new monsters
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

    //helper functions
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

    //main functions
    function _generateRandomDnaFromGrade(uint8 _grade)
        internal
        view
        returns (uint8[22] memory)
    {
        uint256 rand =
            uint256(
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
            if (attempts > 100) {
                require(
                    passingUnique == false,
                    "unable to generate unique dna"
                );
            }
        }
        return rawDna;
    }

    function _generateRandomBeastFromGrade(
        string memory _name,
        uint8 _grade,
        address _address
    ) internal {
        uint8[22] memory dna = _generateRandomDnaFromGrade(_grade);
        uint16 num = 50 * (11 - _grade);
        Stats memory stats = Stats(num, num, num, num, num, num, num, num, num);
        MotherContract.createBeast(
            _name,
            stats,
            1,
            0,
            uint32(block.timestamp + (11 - _grade) * minRecoveryPeriod),
            0,
            0,
            _gradeFromDna(dna),
            _extractionsFromDna(dna),
            dna,
            _address
        );
    }

    function generateStarterBeast(string memory _name) external {
        uint256 tbc = MotherContract.getTamerBeastCount(msg.sender);
        require(tbc == 0, "You already own beasts");
        uint8[22] memory dna = _generateRandomDnaFromGrade(10);
        uint8 grade = _gradeFromDna(dna);
        Stats memory stats = Stats(12, 2, 4, 3, 1, 0, 2, 1, 2);
        MotherContract.createBeast(
            _name,
            stats,
            1,
            0,
            uint32(block.timestamp + (11 - grade) * minRecoveryPeriod),
            0,
            0,
            grade,
            _extractionsFromDna(dna),
            dna,
            msg.sender
        );
    }

    function generateRandomBeastFromGrade(
        string memory _name,
        uint8 _grade,
        address _tamer
    ) external isTrusted() {
        _generateRandomBeastFromGrade(_name, _grade, _tamer);
    }
}
