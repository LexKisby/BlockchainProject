// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "./MotherGetter.sol";

contract MotherSetter is MotherGetter {
    //setter functions

    //#####
    //generation
    //######

    function createBeast(
        string memory _name,
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
}
