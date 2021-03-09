// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "./MotherGetters.sol";

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

        beastToTamer[_beastId] == _to;
        tamerBeastCount[_from] -= 1;
        tamerBeastCount[_to] += 1;
        emit BeastTransfer(_beastId, _from, _to);
    }

    function transferRubies(
        int256 _quantity,
        address _from,
        address _to
    ) external isTrusted() {
        require(currency[_from][1] >= _quantity, "Insufficient funds");

        currency[_from][1] -= _quantity;
        currency[_to][1] += _quantity;
    }

    function tranferEssence(
        int256 _quantity,
        address _from,
        address _to
    ) external isTrusted() {
        currency[_from][0] -= _quantity;
        require(currency[_from][0] >= 0, "Insufficient funds");

        currency[_to][0] += _quantity;
    }

    function depositRubies(int256 _quantity, address _address)
        external
        isTrusted()
    {
        currency[_address][1] += _quantity;
    }

    function depositEssence(int256 _quantity, address _address)
        external
        isTrusted()
    {
        currency[_address][0] += _quantity;
    }

    //#######
    //Contract details
    //#######

    function setLevelUpPrice(int256 _price) external isOwner() {
        levelUpPrice = _price;
        emit ContractUpdate("levelUpPrice", uint256(_price));
    }

    function setXpRequired(uint256 _xp) external isOwner() {
        levelUpXp = _xp;
        emit ContractUpdate("levelUpXp", _xp);
    }

    function setMinRecoveryPeriod(uint256 _time) external isOwner() {
        minRecoveryPeriod = _time;
        emit ContractUpdate("minRecoveryPeriod", _time);
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
