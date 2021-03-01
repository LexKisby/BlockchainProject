// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "./MotherGetter.sol";

contract MotherSetter is MotherGetter {
    //setter functions

    //#####
    //generation
    //######

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
    ) external isTrusted() {
        _initialiseBeast(
            _name,
            _stats,
            _winCount,
            _lossCount,
            _readyTime,
            _grade,
            _extractionsRemaining,
            _dna,
            _address
        );
    }

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
        uint256 _quantity,
        address _from,
        address _to
    ) external isTrusted() {
        require(
            from_balance = currency[_from][1] >= _quantity,
            "Insufficient funds"
        );

        currency[_from][1] -= _quantity;
        currency[_to][1] += _quantity;
    }

    function tranferEssence(
        uint256 _quantity,
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

    function despositEssence(int256 _quantity, address _address)
        external
        isTrusted()
    {
        currency[_address][0] += _quantity;
    }

    //#######
    //Contract details
    //#######

    function setLevelUpPrice(uint256 _price) external isOwner() {
        levelUpPrice = _price;
        emit ContractUpdate("levelUpPrice", _price);
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
    function levelUp(uint256 _beastId) external onlyOwner(_beastId) {
        require(
            beasts[_beastId].xp >= beasts[_beastId].level * levelUpXp,
            "This beast does not have enough XP to level up"
        );
        require(
            currency[msg.sender][1] >= levelUpPrice * beasts[_beastId].level,
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
            beasts[_beastId].level;
        emit LvlUp(_beastId, beasts[_beastId].name, beasts[_beastId].level);
    }

    function changeName(uint256 _beastId, string calldata _newName)
        external
        payable
        onlyOwner(_beastId)
    {
        require(msg.value == etherFee, "Incorrect funds supplied [ether]");
        beasts[_beastId].name = _newName;
        emit NameChange(_beastId, _newName);
    }
}
