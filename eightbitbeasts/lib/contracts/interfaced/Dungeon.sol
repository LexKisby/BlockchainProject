// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import 'Owner.sol';

contract Dungeon is Owner {
    uint256 minRecoveryPeriod = 1 days;

    event DungeonChallenged(uint256 beast1, uint256 beast2, address tamer, uint difficulty);

    address MotherAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    MotherSetter MotherContract = MotherSetter(MotherAddress);

    function updateMotherAddress(address _address) external isOwner() {
        MotherAddress = _address;
        MotherContract = MotherSetter(MotherAddress);

    }
//#####################################################

    //internal functions
    _calculateStrength(MotherSetter.Beast memory _b1, MotherSetter.Beast memory _b2) internal pure returns (uint) {
        return 1;
    }

    _rewardBand(uint _s, uint _d) internal view returns (uint minR, uint rangeR, uint minE, uint rangeE) {
        
        return (0, 1, 0, 0);
    }

    _calcReward(uint _s, uint _d) internal view returns (uint R, uint E) {
        uint minR, uint rangeR, uint minE, uint rangeE = _rewardBand(_s, _d);
        return (minR, minE);
    }

    //external function:
    function enterDungeon(uint256 _beastId1, uint256 beastId2, uint _dungeonLvl) external {
        require(MotherContract.beastToTamer(_beastId1) == msg.sender, "You do not own beast 1");
        require(MotherContract.beastToTamer(_beastId2) == msg.sender, "You do not own beast 2");

        //based on level to adjust difficulty, takes two beasts and then computes a reward
        MotherSetter.Beast memory beast1 = MotherContract.getBeast(_beastId1);
        MotherSetter.Beast memory beast2 = MotherContract.getBeast(_beastId2);

        //assess strength
        uint s = _calculateStrength(beast1, beast2);
        
        //get reward
        uint r, uint e = _calcReward(s, _d);

        //give reward to tamer
        MotherContract.depositCurrency(int(e), msg.sender, 0);
        MotherContract.depositCurrency(int(r), msg.sender, 1);
        //give xp
        MotherContract.addXp(_beastId1, _d);
        MotherContract.addXp(_beastID2, _d);
        //rest them
        MotherContract.triggerRecoveryPeriod(_beast1, 1);
        MotherContract.triggerRecoveryPeriod(_beast2, 1);

        emit DungeonChallenged(_beast1, _beast2, msg.sender, _d);
    }
} 