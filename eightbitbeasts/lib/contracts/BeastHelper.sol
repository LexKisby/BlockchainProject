// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "./BeastMarket.sol";
import "./SafeMath.sol";

contract BeastHelper is BeastMarket {
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    event LevelUp(uint256 beastId, uint256 level);
    event ContractUpdate(string aspect, uint256 newValue);
    event NameChange(uint256 beastId, string newName);
    //various helper functions that dont really belong anywhere else

    uint256 levelUpPrice = 100; //rubies
    uint256 levelUpXp = 100; //xp
    uint256 etherFee = 0.001 ether; //for other exchanges

    //if a monster gets enough xp the tamer can choose to level up the beast
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
        //charge tamer
        currency[msg.sender][1] =
            currency[msg.sender][1] -
            levelUpPrice *
            beasts[_beastId].level;
        emit LevelUp(_beastId, beasts[_beastId].level);
    }

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

    function withdraw() external isOwner() {
        address _owner = _getOwner();
        address payable owner = payable(_owner);
        owner.transfer(address(this).balance);
    }

    function checkBalance() external view isOwner() returns (uint256) {
        return address(this).balance;
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

    //other functions to implement:
    // - buy essence for ether
    // - upgrade stats with essence
    // - create monster from scratch with essence
    // - leaderboards
}
