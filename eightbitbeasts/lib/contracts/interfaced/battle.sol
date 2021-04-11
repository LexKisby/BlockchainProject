// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "./full.sol";

contract Battle is Owner {
    event ChallengeMade(address to, address from, uint256 beastId);
    event Duel(
        address challenger,
        uint256 challengerBeastId,
        address challenged,
        uint256 challengedBeastId,
        address victor
    );

    struct RecChallenge {
        address challenger;
        uint256 beast;
        uint256 index;
        bool expired;
    }

    struct SentChallenge {
        address challenged;
        uint256 beastId;
        uint256 index;
    }

    mapping(address => RecChallenge[]) public tamerRecievedChallenges;
    mapping(address => SentChallenge) public tamerSentChallenge;

    address MotherAddress = 0x22c94BA007a721Ea20af612A1F03fB8F97a0dDd1;
    MotherSetter MotherContract = MotherSetter(MotherAddress);

    function updateMotherAddress(address _address) external isOwner() {
        MotherAddress = _address;
        MotherContract = MotherSetter(MotherAddress);
    }

    //internal functions
    function _findIndex(address _address) internal view returns (uint256) {
        //search auctions
        uint256 counter = 0;
        uint256 max = tamerRecievedChallenges[_address].length - 1;
        while (true) {
            if (counter > max) {
                return counter;
            }
            if (tamerRecievedChallenges[_address][counter].expired == true) {
                return counter;
            }
            counter++;
        }
        revert("exited always true while loop");
    }

    function _mod(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 100;
        int256 y = 50 - (100 * (int256(a) - int256(b))) / int256(a);
        if (y < 0) return 0;
        if (y > 100) return 100;
        return uint256(y);
    }

    function _duel(
        MotherSetter.Beast memory _ally,
        MotherSetter.Beast memory _opp
    ) internal pure returns (bool) {
        uint256 allyHP = uint256(_ally.stats.hp);
        uint256 oppHP = uint256(_opp.stats.hp);
        //uint256 allyLvl = uint256(_ally.level);
        //uint256 oppLvl = uint256(_opp.level);
        uint256 allyAttack =
            (_ally.stats.primaryDamage *
                _mod(_opp.stats.evasion, _ally.stats.attackSpeed) +
                (_ally.stats.secondaryDamage *
                    _mod(_opp.stats.resistance, _ally.stats.accuracy)) /
                2) *
                (50 + _mod(_opp.stats.evasion, _ally.stats.accuracy)) *
                (25 + _mod(_opp.stats.intelligence, _ally.stats.intelligence));
        uint256 oppRebound =
            allyAttack *
                _mod(_opp.stats.constitution, _ally.stats.constitution);

        uint256 oppAttack =
            (_opp.stats.primaryDamage *
                _mod(_ally.stats.evasion, _opp.stats.attackSpeed) +
                (_opp.stats.secondaryDamage *
                    _mod(_ally.stats.resistance, _opp.stats.accuracy)) /
                2) *
                (50 + _mod(_ally.stats.evasion, _opp.stats.accuracy)) *
                (25 + _mod(_ally.stats.intelligence, _opp.stats.intelligence));
        uint256 allyRebound =
            oppAttack * _mod(_ally.stats.constitution, _opp.stats.constitution);

        uint256 Ca = (allyHP * 100**5) / (100 * oppAttack + allyRebound);
        uint256 Cb = (oppHP * 100**5) / (100 * allyAttack + oppRebound);
        if (Ca > Cb) return true;
        else return false;
    }

    //external functions:
    function makeChallenge(address _to, uint256 _beastId) external {
        //makes a challenge to the _to address.
        //_to gets another challenge, and msg.sender changes existing sent challenge to this
        //checks
        require(
            MotherContract.beastToTamer(_beastId) == msg.sender,
            "You do not own this beast"
        );
        require(
            MotherContract.getBeast(_beastId).readyTime < block.timestamp,
            "beast not ready"
        );

        //make challenge
        //find index
        uint256 index = _findIndex(_to);
        uint256 length = tamerRecievedChallenges[_to].length;
        if (index > length) revert("Incorrect index calculated");
        if (index == length)
            tamerRecievedChallenges[_to].push(
                RecChallenge(msg.sender, _beastId, index, false)
            );
        if (index < length)
            tamerRecievedChallenges[_to][index] = RecChallenge(
                msg.sender,
                _beastId,
                index,
                false
            );
        //rewrite prior challenge
        if (tamerSentChallenge[msg.sender].challenged != address(0)) {
            //remove challenge from challenged
            tamerRecievedChallenges[tamerSentChallenge[msg.sender].challenged][
                tamerSentChallenge[msg.sender].index
            ]
                .expired = true;
        }
        //update sent challenge
        tamerSentChallenge[msg.sender] = SentChallenge(_to, _beastId, index);

        emit ChallengeMade(_to, msg.sender, _beastId);
    }

    function acceptChallenge(uint256 _index, uint256 _beastId) external {
        //checks
        //challenge exists
        require(
            tamerRecievedChallenges[msg.sender][_index].expired == false,
            "This challenge has expired"
        );
        //beasts ready
        MotherSetter.Beast memory ally = MotherContract.getBeast(_beastId);
        MotherSetter.Beast memory opp =
            MotherContract.getBeast(
                tamerRecievedChallenges[msg.sender][_index].beast
            );
        require(ally.readyTime < block.timestamp, "Your beast is not ready");
        require(opp.readyTime < block.timestamp, "Opponent beast is not ready");

        bool result = _duel(ally, opp);

        uint32 allyXp;
        uint32 oppXp;
        address victor;

        if (result) {
            //win for ally
            allyXp = 50 * opp.level;
            oppXp = 10 * ally.level;
            MotherContract.battleWin(ally.id);
            MotherContract.battleLoss(opp.id);
            //rest loser
            MotherContract.triggerRecoveryPeriod(opp.id, 1);
            victor = msg.sender;
        } else {
            //win for opp
            allyXp = 10 * opp.level;
            oppXp = 50 * ally.level;
            MotherContract.battleWin(opp.id);
            MotherContract.battleLoss(ally.id);

            MotherContract.triggerRecoveryPeriod(ally.id, 1);
            victor = tamerRecievedChallenges[msg.sender][_index].challenger;
        }
        MotherContract.addXp(ally.id, allyXp);
        MotherContract.addXp(opp.id, oppXp);

        emit Duel(
            tamerRecievedChallenges[msg.sender][_index].challenger,
            opp.id,
            msg.sender,
            ally.id,
            victor
        );
    }
}
