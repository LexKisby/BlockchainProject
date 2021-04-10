// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

contract Owner {
    address private owner;
    mapping(address => bool) trustedAddresses;

    modifier isTrusted() {
        require(
            trustedAddresses[msg.sender] == true,
            "Request is not from a trusted source"
        );
        _;
    }

    function addTrusted(address _address) external isOwner() {
        trustedAddresses[_address] = true;
    }

    function removeTrusted(address _address) external isOwner() {
        trustedAddresses[_address] = false;
    }

    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        trustedAddresses[owner] = true;
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address
     * @return address of owner
     */
    function _getOwner() public view returns (address) {
        return owner;
    }
}

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
    ) internal {
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

    function dnaExists(uint8[22] memory _dna) external view returns (bool) {
        return _checkUniqueDna(_dna) == false;
    }
}

contract MotherSetter is MotherGetter {
    //setter functions

    //#####
    //beast params
    //#####
    function triggerRecoveryPeriod(uint256 _beastId, uint32 _factor)
        external
        isTrusted()
    {
        beasts[_beastId].readyTime = uint32(
            block.timestamp + _factor * minRecoveryPeriod
        );
    }

    function setReadyTime(uint256 _beastId, uint32 _time) external isTrusted() {
        beasts[_beastId].readyTime = _time;
    }

    function reduceExtractions(uint256 _beastId) external isTrusted() {
        require(beasts[_beastId].extractionsRemaining > 0);
        beasts[_beastId].extractionsRemaining--;
    }

    function battleWin(uint256 _beastId) external isTrusted() {
        beasts[_beastId].winCount++;
    }

    function battleLoss(uint256 _beastId) external isTrusted() {
        beasts[_beastId].lossCount++;
    }

    function addXp(uint256 _beastId, uint32 _xp) external isTrusted() {
        beasts[_beastId].xp = beasts[_beastId].xp + _xp;
    }

    //#####
    //generation
    //######

    function createBeast(
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
        address _address
    ) external isTrusted() {
        _initialiseBeast(
            _name,
            _stats,
            _level,
            _xp,
            _readyTime,
            _winCount,
            _lossCount,
            _grade,
            _extractionsRemaining,
            _dna,
            _address
        );
    }

    function setStats(
        uint16 _beastId,
        uint16 _hp,
        uint16 _attackSpeed,
        uint16 _evasion,
        uint16 _primaryDamage,
        uint16 _secondaryDamage,
        uint16 _resistance,
        uint16 _accuracy,
        uint16 _constitution,
        uint16 _intelligence
    ) external isTrusted() {
        beasts[_beastId].stats.hp = _hp;
        beasts[_beastId].stats.attackSpeed = _attackSpeed;
        beasts[_beastId].stats.evasion = _evasion;
        beasts[_beastId].stats.primaryDamage = _primaryDamage;
        beasts[_beastId].stats.secondaryDamage = _secondaryDamage;
        beasts[_beastId].stats.resistance = _resistance;
        beasts[_beastId].stats.accuracy = _accuracy;
        beasts[_beastId].stats.constitution = _constitution;
        beasts[_beastId].stats.intelligence = _intelligence;
        emit StatBoost(_beastId, beasts[_beastId].name, beasts[_beastId].stats);
    }

    //#######
    //Ownership
    //########

    function transferBeast(
        uint256 _beastId,
        address _from,
        address _to
    ) external isTrusted() {
        require(
            beastToTamer[_beastId] == _from,
            "The beast does not belong to the 'from' address"
        );

        beastToTamer[_beastId] = _to;
        tamerBeastCount[_from] -= 1;
        tamerBeastCount[_to] += 1;
        emit BeastTransfer(_beastId, _from, _to);
    }

    function transferCurrency(
        int256 _quantity,
        address _from,
        address _to,
        uint8 _type
    ) external isTrusted() {
        currency[_from][_type] -= _quantity;
        require(currency[_from][_type] >= 0, "Insufficient funds");

        currency[_to][_type] += _quantity;
    }

    function depositCurrency(
        int256 _quantity,
        address _address,
        uint8 _type
    ) external isTrusted() {
        currency[_address][_type] += _quantity;
    }

    //############
    //user facing functions
    function levelUp(uint256 _beastId) external beastOwner(_beastId) {
        require(
            beasts[_beastId].xp >= beasts[_beastId].level * levelUpXp,
            "This beast does not have enough XP to level up"
        );
        require(
            currency[msg.sender][1] >=
                levelUpPrice * int32(beasts[_beastId].level),
            "Insufficient funds [rubies]"
        );
        beasts[_beastId].xp = uint32(
            beasts[_beastId].xp - beasts[_beastId].level * levelUpXp
        );
        beasts[_beastId].level++;
        //+1 all stats
        beasts[_beastId].stats.hp++;
        beasts[_beastId].stats.attackSpeed++;
        beasts[_beastId].stats.evasion++;
        beasts[_beastId].stats.primaryDamage++;
        beasts[_beastId].stats.secondaryDamage++;
        beasts[_beastId].stats.resistance++;
        beasts[_beastId].stats.accuracy++;
        beasts[_beastId].stats.constitution++;
        beasts[_beastId].stats.intelligence++;

        //charge tamer
        currency[msg.sender][1] =
            currency[msg.sender][1] -
            levelUpPrice *
            int32(beasts[_beastId].level);
        emit LvlUp(_beastId, beasts[_beastId].name, beasts[_beastId].level);
    }
}

contract Generator is Owner {
    //handles the generation of new monsters
    uint256 minRecoveryPeriod = 1 days;

    //needs changing
    address MotherAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    MotherSetter MotherContract = MotherSetter(MotherAddress);

    function updateMotherAddress(address _address) external isOwner() {
        MotherAddress = _address;
        MotherContract = MotherSetter(MotherAddress);
    }

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
            _num = _num / 10;
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
        MotherCore.Stats memory stats =
            MotherCore.Stats(num, num, num, num, num, num, num, num, num);
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

    //########################
    //external functions
    //#############

    function generateStarterBeast(string memory _name) external {
        uint256 tbc = MotherContract.tamerBeastCount(msg.sender);
        require(tbc == 0, "You already own beasts");
        uint8[22] memory dna = _generateRandomDnaFromGrade(10);
        uint8 grade = _gradeFromDna(dna);
        MotherCore.Stats memory stats =
            MotherCore.Stats(12, 2, 4, 3, 1, 0, 2, 1, 2);
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

contract Fusion is Owner {
    uint256 minRecoveryPeriod = 1 days;

    address MotherAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    MotherSetter MotherContract = MotherSetter(MotherAddress);
    address MarketAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    Market MarketContract = Market(MarketAddress);

    function updateMotherAddress(address _address) external isOwner() {
        MotherAddress = _address;
        MotherContract = MotherSetter(MotherAddress);
    }

    function updateMarketAddress(address _address) external isOwner() {
        MarketAddress = _address;
        MarketContract = Market(MarketAddress);
    }

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
        MotherSetter.Beast memory _id1,
        MotherSetter.Beast memory _id2,
        uint256 _type
    ) internal pure returns (MotherSetter.Stats memory) {
        //normal calculation
        if (_type == 1) {
            MotherCore.Stats memory newStats =
                MotherCore.Stats(
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
            MotherCore.Stats memory newStats =
                MotherCore.Stats(
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
        MotherSetter.Beast memory _primaryBeast,
        MotherSetter.Beast memory _secondaryBeast,
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
        MotherSetter.Beast memory _id1,
        MotherSetter.Beast memory _id2
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
        MotherSetter.Beast memory _primaryBeast,
        MotherSetter.Beast memory _secondaryBeast,
        string memory _name
    ) internal returns (bool) {
        //create new data
        MotherSetter.Stats memory newStats =
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
        MotherSetter.Beast memory _primaryBeast,
        MotherSetter.Beast memory _secondaryBeast,
        string memory _name
    ) internal returns (bool) {
        //create new data
        MotherSetter.Stats memory newStats =
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
        MotherSetter.Beast memory _primaryBeast,
        MotherSetter.Beast memory _secondaryBeast,
        string memory _name
    ) internal returns (bool) {
        //create new data
        MotherSetter.Stats memory newStats =
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
        MotherSetter.Beast memory _primaryBeast,
        MotherSetter.Beast memory _secondaryBeast,
        string memory _name
    ) internal returns (bool) {
        //create new data
        MotherSetter.Stats memory newStats =
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
            MotherContract.beastToTamer(_primaryId) == msg.sender,
            "You do not own this beast"
        );
        //bring beasts into memory
        MotherCore.Beast memory primaryBeast =
            MotherContract.getBeast(_primaryId);
        MotherSetter.Beast memory secondaryBeast =
            MotherContract.getBeast(_secondaryId);
        //check if owns secondary
        bool ownsSecondary =
            MotherContract.beastToTamer(_secondaryId) == msg.sender;
        bool ownsExtract;
        //if we own the secondary, continue
        if (ownsSecondary != true) {
            (address extractOwner, , uint32 extractExpiry) =
                MarketContract.extractToTamer(_secondaryId);
            ownsExtract =
                extractOwner == msg.sender &&
                extractExpiry > block.timestamp;
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
            MarketContract.removeExtract(_secondaryId);
        }
        return success;
    }
}

contract Market is Owner {
    event BeastAddedToAuction(
        uint256 beastId,
        address seller,
        uint256 startPrice
    );
    event BeastAddedForExtract(uint256 beastId, address seller, uint256 price);
    event RubiesExchangedForEssence(address tamer);
    event RetrievedBeast(uint256 beastId, address tamer);
    event BeastAuctioned(uint256 beastId, address newTamer, uint256 price);
    event BeastExtractAuctioned(uint256 beastId, address tamer, uint256 price);

    struct Extract {
        address owner;
        uint256 beastId;
        uint32 expiry;
    }

    struct Auction {
        MotherSetter.Beast beast;
        address seller;
        uint256 startPrice;
        uint256 endPrice;
        uint32 startTime;
        uint32 endTime;
        bool retrieved;
    }

    struct ExtractAuction {
        Extract extract;
        address seller;
        uint256 price;
        uint32 endTime;
        bool retrieved;
    }

    mapping(uint256 => Extract) public extractToTamer;
    Auction[] public auctions;
    ExtractAuction[] public extractAuctions;

    address MotherAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    MotherSetter MotherContract = MotherSetter(MotherAddress);

    function updateMotherAddress(address _address) external isOwner() {
        MotherAddress = _address;
        MotherContract = MotherSetter(MotherAddress);
    }

    //#####################################

    function exchangeRubiesForEssence() external {
        int256 balance = MotherContract.currency(msg.sender, 1);
        require(balance >= 1000, "Insufficient funds [rubies]");
        MotherContract.depositCurrency(-1000, msg.sender, 1);
        MotherContract.depositCurrency(10, msg.sender, 0);
        emit RubiesExchangedForEssence(msg.sender);
    }

    //setters

    function auctionBeast(
        uint256 _beastId,
        uint256 _startPrice,
        uint256 _endPrice,
        uint32 _endTime
    ) external {
        require(
            MotherContract.beastToTamer(_beastId) == msg.sender,
            "You do not own this beast"
        );
        MotherSetter.Beast memory beast = MotherContract.getBeast(_beastId);
        require(
            beast.readyTime <= block.timestamp,
            "This beast is not yet ready"
        );
        require(_endTime > block.timestamp, "This auction has no duration");
        //find earliest spot in auction list
        uint256 len = auctions.length;
        uint256 index = _findIndex(1);
        //insert
        if (index < len) {
            auctions[index] = Auction(
                beast,
                msg.sender,
                _startPrice,
                _endPrice,
                uint32(block.timestamp),
                _endTime,
                false
            );
        }
        if (index == len) {
            auctions.push(
                Auction(
                    beast,
                    msg.sender,
                    _startPrice,
                    _endPrice,
                    uint32(block.timestamp),
                    _endTime,
                    false
                )
            );
        }
        if (index > len) {
            revert("erroneous index calculated");
        }
        //revoke ownership to contract
        MotherContract.transferBeast(_beastId, msg.sender, address(this));
        emit BeastAddedToAuction(_beastId, msg.sender, _startPrice);
    }

    function auctionBeastExtract(
        uint256 _beastId,
        uint256 _price,
        uint32 _endTime
    ) external {
        require(
            MotherContract.beastToTamer(_beastId) == msg.sender,
            "You do not own this beast"
        );
        MotherSetter.Beast memory beast = MotherContract.getBeast(_beastId);
        require(
            beast.readyTime <= block.timestamp,
            "This beast is not yet ready"
        );
        require(_endTime > block.timestamp, "This auction has no duration");
        //find earliest spot in auction list
        uint256 len = extractAuctions.length;
        uint256 index = _findIndex(2);
        //insert
        if (index < len) {
            extractAuctions[index] = ExtractAuction(
                Extract(address(this), _beastId, 0),
                msg.sender,
                _price,
                _endTime,
                false
            );
        }
        if (index == len) {
            extractAuctions.push(
                ExtractAuction(
                    Extract(address(this), _beastId, 0),
                    msg.sender,
                    _price,
                    _endTime,
                    false
                )
            );
        }
        if (index > len) {
            revert("erroneous index calculated");
        }
        //set ready time to later
        MotherContract.setReadyTime(_beastId, _endTime);
        emit BeastAddedForExtract(_beastId, msg.sender, _price);
    }

    function retrieve(
        uint256 _beastId,
        uint256 _auctionNo,
        uint256 _type
    ) external {
        if (_type == 1) {
            //regular auction
            //check params
            require(
                msg.sender == auctions[_auctionNo].seller,
                "You are not the seller of this auction"
            );
            require(
                auctions[_auctionNo].beast.id == _beastId,
                "The beast you are trying to retrieve does not match the one in this auction"
            );
            require(
                auctions[_auctionNo].retrieved == false,
                "This monster has already been sold or retrieved"
            );
            auctions[_auctionNo].retrieved = true;
            MotherContract.transferBeast(_beastId, address(this), msg.sender);
            emit RetrievedBeast(_beastId, msg.sender);
        }
        if (_type == 2) {
            //extraction
            //check params
            require(
                msg.sender == extractAuctions[_auctionNo].seller,
                "You are not the seller of this Extract Auction"
            );
            require(
                extractAuctions[_auctionNo].extract.beastId == _beastId,
                "The beast you are trying to retrieve does not match the one in this extract auction"
            );
            require(
                extractAuctions[_auctionNo].retrieved == false,
                "The beast you are trying to retrieve has already been extracted or retrieved"
            );
            extractAuctions[_auctionNo].retrieved == true;
            MotherContract.setReadyTime(_beastId, uint32(block.timestamp));
            emit RetrievedBeast(_beastId, msg.sender);
        }
    }

    function buyBeastFromAuction(uint256 _beastId, uint256 _auctionNo)
        external
    {
        Auction storage auction = auctions[_auctionNo];
        require(
            auction.beast.id == _beastId,
            "The beast you are trying to buy does not match the one in this auction"
        );
        require(
            auction.retrieved == false,
            "This monster has already been sold or retrieved"
        );
        require(
            auction.endTime > uint32(block.timestamp),
            "This auction has expired"
        );
        //calculate price
        uint256 duration = auction.endTime - auction.startTime;
        uint256 remaining = auction.endTime - block.timestamp;
        uint256 deltaPrice = auction.startPrice - auction.endPrice;
        uint256 price = auction.endPrice + (deltaPrice / duration) * remaining;
        //charge
        int256 balance = MotherContract.currency(msg.sender, 0);
        require(price < uint256(balance), "Insufficient funds [essence]");
        MotherContract.transferCurrency(
            int256(price),
            msg.sender,
            auction.seller,
            0
        );
        //change owners
        MotherContract.transferBeast(_beastId, address(this), msg.sender);
        //signal auction as ended
        auctions[_auctionNo].retrieved = true;
        //fire event
        emit BeastAuctioned(_beastId, msg.sender, price);
    }

    function buyExtractFromAuction(uint256 _beastId, uint256 _auctionNo)
        external
    {
        ExtractAuction storage extractAuction = extractAuctions[_auctionNo];
        require(
            extractAuction.extract.beastId == _beastId,
            "The beast you are trying to buy does not match the one in this auction"
        );
        require(
            extractAuction.retrieved == false,
            "This monster has already been sold or retrieved"
        );
        require(
            extractAuction.endTime > uint32(block.timestamp),
            "This auction has expired"
        );
        int256 balance = MotherContract.currency(msg.sender, 0);
        require(
            extractAuction.price < uint256(balance),
            "Insufficient funds [essence]"
        );
        MotherContract.transferCurrency(
            int256(extractAuction.price),
            msg.sender,
            extractAuction.seller,
            0
        );
        //change owner of extract
        extractToTamer[_beastId] = Extract(
            msg.sender,
            _beastId,
            uint32(block.timestamp + 1 days)
        );
        //put owners beast to recovery for a day
        MotherContract.triggerRecoveryPeriod(_beastId, 1);
        //signal auction ended
        extractAuctions[_auctionNo].retrieved = true;
        //fire event
        emit BeastExtractAuctioned(_beastId, msg.sender, extractAuction.price);
    }

    //helpers
    function _findIndex(uint256 _type) internal view returns (uint256) {
        if (_type == 1) {
            //search auctions
            uint256 counter = 0;
            uint256 max = auctions.length - 1;
            while (true) {
                if (auctions[counter].retrieved == true) {
                    return counter;
                }
                counter++;
                if (counter > max) {
                    return counter;
                }
            }
            revert("exited always true while loop");
        }
        if (_type == 2) {
            //search extract auctions
            uint256 counter = 0;
            uint256 max = auctions.length - 1;
            while (true) {
                if (auctions[counter].retrieved == true) {
                    return counter;
                }
                counter++;
                if (counter > max) {
                    return counter;
                }
            }
            revert("exited always true while loop");
        }
        revert("Wrong type passed to _findIndex");
    }

    function getExtracts() external view returns (uint256[] memory) {
        uint256 len = MotherContract.howManyBeasts();
        uint256[] memory extractsOwnedBySender;
        uint256 count = 0;
        uint256 index = 0;
        while (count < len) {
            if (extractToTamer[count].owner == msg.sender) {
                extractsOwnedBySender[index] = count;
                index++;
            }
            count++;
        }
        return extractsOwnedBySender;
    }

    function removeExtract(uint256 _beastId) external isTrusted() {
        extractToTamer[_beastId].owner = address(0);
    }
}

contract Dungeon is Owner {
    uint256 minRecoveryPeriod = 1 days;

    event DungeonChallenged(
        uint256 beast1,
        uint256 beast2,
        address tamer,
        uint256 difficulty
    );
    event DungeonFailed(
        uint256 beast1,
        uint256 beast2,
        address tamer,
        uint256 difficulty
    );

    address MotherAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    MotherSetter MotherContract = MotherSetter(MotherAddress);

    function updateMotherAddress(address _address) external isOwner() {
        MotherAddress = _address;
        MotherContract = MotherSetter(MotherAddress);
    }

    //#####################################################

    //internal functions
    function _calculateStrength(
        MotherCore.Beast memory _b1,
        MotherCore.Beast memory _b2
    ) internal pure returns (uint256) {
        uint256 s1 =
            _b1.stats.attackSpeed *
                (_b1.stats.primaryDamage + _b1.stats.secondaryDamage) *
                _b1.stats.accuracy +
                _b1.stats.resistance +
                _b1.stats.evasion *
                _b1.stats.constitution +
                _b1.stats.hp;
        uint256 s2 =
            _b2.stats.attackSpeed *
                (_b2.stats.primaryDamage + _b2.stats.secondaryDamage) *
                _b2.stats.accuracy +
                _b2.stats.resistance +
                _b2.stats.evasion *
                _b2.stats.constitution +
                _b2.stats.hp;
        return s1 + s2;
    }

    function _rewardBand(uint256 _s, uint256 _d)
        internal
        pure
        returns (
            uint256 minR,
            uint256 rangeR,
            uint256 minE,
            uint256 rangeE
        )
    {
        if (_d > 5) {
            if (_d > 7) {
                if (_d == 8) {
                    if (_s < 250000000) {
                        return (0, 0, 0, 0);
                    }
                }
                if (_d == 9) {
                    if (_s < 1000000000) {
                        return (0, 0, 0, 0);
                    }
                }
                if (_d == 10) {
                    if (_s < 1750000000) {
                        return (0, 0, 0, 0);
                    }
                }
            } else {
                if (_d == 6) {
                    if (_s < 2000000) {
                        return (0, 0, 0, 0);
                    }
                }
                if (_d == 7) {
                    if (_s < 40000000) {
                        return (0, 0, 0, 0);
                    }
                }
            }
        } else {
            if (_d > 3) {
                if (_d == 4) {
                    if (_s < 10000) {
                        return (0, 0, 0, 0);
                    }
                }
                if (_d == 5) {
                    if (_s < 200000) {
                        return (0, 0, 0, 0);
                    }
                }
            } else {
                if (_d == 1) {}
                if (_d == 2) {
                    if (_s < 300) {
                        return (0, 0, 0, 0);
                    }
                }
                if (_d == 3) {
                    if (_s < 1000) {
                        return (0, 0, 0, 0);
                    }
                }
            }
        }
        minR = _s / 2**(_d + 1);
        rangeR = 2**_d * _d**3;
        if (minR > 5**_d * 2) {
            minR = 5**_d * 2;
        }
        minE = 0;
        rangeE = 0;
        if (_d > 1) {
            rangeE = 2**(_d - 1);
        }
        return (minR, rangeR, minE, rangeE);
    }

    function _calcReward(uint256 _s, uint256 _d)
        internal
        view
        returns (uint256 R, uint256 E)
    {
        uint256 minR;
        uint256 rangeR;
        uint256 minE;
        uint256 rangeE;
        (minR, rangeR, minE, rangeE) = _rewardBand(_s, _d);
        R =
            minR +
            ((uint256(keccak256(abi.encodePacked(block.timestamp))) % 100) *
                rangeR) /
            100;
        E =
            minE +
            ((uint256(keccak256(abi.encodePacked(block.timestamp))) % 100) *
                rangeE) /
            100;

        return (R, E);
    }

    //external function:
    function enterDungeon(
        uint256 _beastId1,
        uint256 _beastId2,
        uint32 _dungeonLvl
    ) external {
        require(
            MotherContract.beastToTamer(_beastId1) == msg.sender,
            "You do not own beast 1"
        );
        require(
            MotherContract.beastToTamer(_beastId2) == msg.sender,
            "You do not own beast 2"
        );

        //based on level to adjust difficulty, takes two beasts and then computes a reward
        MotherSetter.Beast memory beast1 = MotherContract.getBeast(_beastId1);
        MotherSetter.Beast memory beast2 = MotherContract.getBeast(_beastId2);
        require(beast1.readyTime <= block.timestamp, "Beast 1 is not ready");
        require(beast2.readyTime <= block.timestamp, "Beast 2 is not ready");

        //assess strength
        uint256 s = _calculateStrength(beast1, beast2);

        //get reward
        uint256 r;
        uint256 e;
        (r, e) = _calcReward(s, _dungeonLvl);
        uint32 xp = _dungeonLvl;
        if (r > 0) {
            xp = _dungeonLvl * 10;
        }

        //give reward to tamer
        MotherContract.depositCurrency(int256(e), msg.sender, 0);
        MotherContract.depositCurrency(int256(r), msg.sender, 1);
        //give xp
        MotherContract.addXp(_beastId1, xp);
        MotherContract.addXp(_beastId2, xp);
        //rest them
        MotherContract.triggerRecoveryPeriod(_beastId1, 1);
        MotherContract.triggerRecoveryPeriod(_beastId2, 1);

        if (r > 0) {
            emit DungeonChallenged(
                _beastId1,
                _beastId2,
                msg.sender,
                _dungeonLvl
            );
        } else {
            emit DungeonFailed(_beastId1, _beastId2, msg.sender, _dungeonLvl);
        }
    }
}
