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
        returns (int256[2] memory);

    function depositRubies(int256 _quantity, address _address) external;

    function depositEssence(int256 _quantity, address _address) external;

    function transferBeast(
        uint256 _beastId,
        address _from,
        address _to
    ) external;

    function setReadyTime(uint256 _beastId, uint32 _time) external;

    function transferEssence(
        int256 _quantity,
        address _from,
        address _to
    ) external;

    function howManyBeasts() external view returns (uint256);
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
    Auction[] public auctions;
    ExtractAuction[] public extractAuctions;

    address MotherAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    MotherInterface MotherContract = MotherInterface(MotherAddress);

    function updateMotherAddress(address _address) external isOwner() {
        MotherAddress = _address;
        MotherContract = MotherInterface(MotherAddress);
    }

    //#####################################

    function exchangeRubiesForEssence() external {
        int256[2] memory balance = MotherContract.getNamedCurrency(msg.sender);
        require(balance[1] >= 1000, "Insufficient funds [rubies]");
        MotherContract.depositRubies(-1000, msg.sender);
        MotherContract.depositEssence(10, msg.sender);
        emit RubiesExchangedForEssence(msg.sender);
    }

    //####
    //getters

    function getAuctions() external view returns (Auction[] memory) {
        return auctions;
    }

    function getExtractAuctions()
        external
        view
        returns (ExtractAuction[] memory)
    {
        return extractAuctions;
    }

    //setters

    function auctionBeast(
        uint256 _beastId,
        uint256 _startPrice,
        uint256 _endPrice,
        uint32 _endTime
    ) external {
        require(
            MotherContract.isTamer(_beastId, msg.sender),
            "You do not own this beast"
        );
        MotherInterface.Beast memory beast = MotherContract.getBeast(_beastId);
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
            MotherContract.isTamer(_beastId, msg.sender),
            "You do not own this beast"
        );
        MotherInterface.Beast memory beast = MotherContract.getBeast(_beastId);
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
        int256[2] memory balance = MotherContract.getNamedCurrency(msg.sender);
        require(price < uint256(balance[0]), "Insufficient funds [essence]");
        MotherContract.transferEssence(
            int256(price),
            msg.sender,
            auction.seller
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
        int256[2] memory balance = MotherContract.getNamedCurrency(msg.sender);
        require(
            extractAuction.price < uint256(balance[0]),
            "Insufficient funds [essence]"
        );
        MotherContract.transferEssence(
            int256(extractAuction.price),
            msg.sender,
            extractAuction.seller
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

    function ownsExtract(uint256 _beastId, address _tamer)
        external
        view
        returns (bool)
    {
        return extractToTamer[_beastId].owner == _tamer;
    }

    function removeExtract(uint256 _beastId) external isTrusted() {
        extractToTamer[_beastId].owner = address(0);
    }

    function getExtract(uint256 _beastId)
        external
        view
        returns (Extract memory)
    {
        return extractToTamer[_beastId];
    }
}
