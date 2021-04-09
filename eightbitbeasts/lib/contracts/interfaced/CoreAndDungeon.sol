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

contract Dungeon is Owner {
    uint256 minRecoveryPeriod = 1 days;

    event DungeonChallenged(uint256 beast1, uint256 beast2, address tamer, uint difficulty);
    event DungeonFailed(uint256 beast1, uint256 beast2, address tamer, uint difficulty);

    address MotherAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    MotherSetter MotherContract = MotherSetter(MotherAddress);

    function updateMotherAddress(address _address) external isOwner() {
        MotherAddress = _address;
        MotherContract = MotherSetter(MotherAddress);

    }
//#####################################################

    //internal functions
    _calculateStrength(MotherSetter.Beast memory _b1, MotherSetter.Beast memory _b2) internal pure returns (uint) {
        uint s1 = _b1.attackSpeed * (_b1.primaryDamage + _b1.secondaryDamage) * _b1.accuracy + _b1.resistance + _b1.evasion * _b1.constitution + _b1.hp;
        uint s2 = _b2.attackSpeed * (_b2.primaryDamage + _b2.secondaryDamage) * _b2.accuracy + _b2.resistance + _b2.evasion * _b2.constitution + _b2.hp;
        return s1+s2;
    }

    _rewardBand(uint _s, uint _d) internal view returns (uint minR, uint rangeR, uint minE, uint rangeE) {
        if (_d > 5) {
            if (_d > 7) {
                if (_d == 8) {
                    if (_s < 250000000) {
                        return (0,0,0,0);
                    }
                }
                if (_d == 9) {
                    if (_s < 1000000000) {
                        return (0,0,0,0);
                    }
                }
                if (_d == 10) {
                    if (_s < 1750000000) {
                        return (0,0,0,0);
                    }
                }
            } else {
                if (_d == 6) {
                    if (_s < 2000000) {
                        return (0,0,0,0);
                    }
                }
                if (_d == 7) {
                    if (_s < 40000000) {
                        return (0,0,0,0);
                    }
                }
            }
        } else {
            if (_d > 3) {
                if (_d == 4) {
                    if (_s < 10000) {
                        return (0,0,0,0);
                    }
                }
                if (_d == 5) {
                    if (_s < 200000) {
                        return (0,0,0,0);
                    }
                }
            } else {
                if (_d == 1) {}
                if (_d == 2) {
                    if (_s < 300) {
                        return (0,0,0,0);
                    }
                }
                if (_d == 3) {
                    if (_s < 1000) {
                        return (0,0,0,0);
                    }
                }
            }
        }
        uint minR = _s / 2**(d+1);
        uint rangeR = 2 ** _d * _d**3;
        if (minR > 5**d * 2);
        uint minE = 0;
        uint rangeE = 0;
        if (_d > 1) {
            rangeE = 2 ** (_d - 1);
        }
        return (minR, rangeR, minE, rangeE);
    }

    _calcReward(uint _s, uint _d) internal view returns (uint R, uint E) {
        uint minR, uint rangeR, uint minE, uint rangeE = _rewardBand(_s, _d);
        uint R = minR + (uint(keccak256(abi.encodePacked(block.timestamp))) % 100) * rangeR / 100;
        uint E = minE + (uint(keccak256(abi.encodePacked(block.timestamp))) % 100) * rangeE / 100;

        return (R, E);
    }

    //external function:
    function enterDungeon(uint256 _beastId1, uint256 beastId2, uint _dungeonLvl) external {
        require(MotherContract.beastToTamer(_beastId1) == msg.sender, "You do not own beast 1");
        require(MotherContract.beastToTamer(_beastId2) == msg.sender, "You do not own beast 2");

        //based on level to adjust difficulty, takes two beasts and then computes a reward
        MotherSetter.Beast memory beast1 = MotherContract.getBeast(_beastId1);
        MotherSetter.Beast memory beast2 = MotherContract.getBeast(_beastId2);
        require(beast1.readyTime <= block.timestamp, "Beast 1 is not ready");
        require(beast2.readyTime <= block.timestamp, "Beast 2 is not ready");

        //assess strength
        uint s = _calculateStrength(beast1, beast2);
        
        //get reward
        uint r, uint e = _calcReward(s, _d);
        uint xp = _d;
        if (r>0) {
            xp = _d * 10;
        }

        //give reward to tamer
        MotherContract.depositCurrency(int(e), msg.sender, 0);
        MotherContract.depositCurrency(int(r), msg.sender, 1);
        //give xp
        MotherContract.addXp(_beastId1, _d);
        MotherContract.addXp(_beastId2, _d);
        //rest them
        MotherContract.triggerRecoveryPeriod(_beast1, 1);
        MotherContract.triggerRecoveryPeriod(_beast2, 1);

        if (r>0){
        emit DungeonChallenged(_beast1, _beast2, msg.sender, _d);
        } else {
            emit DungeonFailed(_beast1, _beast2, msg,sender, _d);
        }
    }
} 