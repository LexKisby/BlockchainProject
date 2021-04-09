// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import 'Owner.sol';

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