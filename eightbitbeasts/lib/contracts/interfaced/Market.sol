// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "./Owner.sol";

interface MotherInterface {
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

    function createBeast(
        string calldata _name,
        Stats memory _stats,
        uint256 _level,
        uint256 _xp,
        uint256 _readyTime,
        uint256 _winCount,
        uint256 _lossCount,
        uint256 _grade,
        uint256 _extractionsRemaining,
        uint8[22] memory _dna,
        address _address
    ) external;

    function getTamerBeastCount(address _tamer) external view returns (uint256);

    function dnaExists(uint8[22] memory _dna) external view returns (bool);

    function getBeast(uint256 _beastId) external view returns (Beast memory);

    function isTamer(uint256 _beastId, address _tamer)
        external
        view
        returns (bool);

    function reduceExtractions(uint256 _beastId) external;

    function triggerRecoveryPeriod(uint256 _beastId, uint32 _factor) external;

    function getNamedCurrency(address _address)
        external
        view
        returns (uint256[2] memory);

    function depositRubies(int256 _quantity, address _address) external;

    function depositEssence(int256 _quantity, address _address) external;
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
    event BeastExtarctAuctioned(uint256 beastId, address tamer, uint256 price);

    struct Extract {
        address owner;
        uint256 beastId;
        uint32 expiry;
    }

    struct Auction {
        MotherInterface.Beast beast;
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

    mapping(uint256 => Extract) extractToTamer;
    Auction[] public Auctions;
    ExtractAuction[] public extractAuctions;

    address MotherAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    MotherInterface MotherContract = MotherInterface(MotherAddress);

    //#####################################

    function exchangeRubiesForEssence() external {
        uint256[2] memory balance = MotherContract.getNamedCurrency(msg.sender);
        require(balance[1] >= 1000, "Insufficient funds [rubies]");
        MotherContract.depositRubies(-1000, msg.sender);
        MotherContract.depositEssence(10, msg.sender);
        emit RubiesExchangedForEssence(msg.sender);
    }
}
