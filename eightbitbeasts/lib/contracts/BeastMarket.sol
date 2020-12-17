// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "./BeastFusion.sol";
import "./SafeMath.sol";

contract BeastMarket is BeastFusion {
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

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

    //###############################################
    //This contract handles market functions, such as calls for:
    //-current monsters available for auction      x
    //-current monsters available for an extract   x
    //as well as transactions serving to :
    //-buy a momster at auction                    x
    //-buy an extract                              x
    //put up a monster for auction                 x
    //put up a monster for extract                 x
    //retreive a monster from auction or extract   x
    //get all extracts owned by a tamer

    //also implements the currency systems
    //ruby - secondary currency system, common. used for minor details, like lvl up
    //essence - primary currency system, rare. used for significant upgrades and trades.
    //###############################################
    //auction struct to handle auctions, extract struct exists in beastfusion
    struct Auction {
        Beast beast;
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

    //currency, rubies and essence
    //[0] is essence [1] is ruby
    mapping(address => uint256[2]) currency;
    Auction[] public auctions;
    ExtractAuction[] public extractAuctions;

    //#######################################################################
    //currency functions

    function getCurrency() external view returns (uint256[2] memory) {
        return currency[msg.sender];
    }

    function exchangeRubyForEssence() external {
        require(currency[msg.sender][1] >= 1000, "Insufficient rubies");
        currency[msg.sender][0] = currency[msg.sender][0] + 10;
        currency[msg.sender][1] = currency[msg.sender][1] - 1000;
        emit RubiesExchangedForEssence(msg.sender);
    }

    //#########################################################################
    //Auction fucntions

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

    //puts up beast for auction
    function auctionBeast(
        uint256 _beastId,
        uint256 _startPrice,
        uint256 _endPrice,
        uint32 _endTime
    ) external onlyOwner(_beastId) {
        require(_isReady(_beastId), "This beast is not yet ready");
        require(_endTime > block.timestamp, "This auction has no duration");
        //find earliest spot in auction list
        uint256 len = auctions.length;
        uint256 index = _findIndex(1);
        //insert
        if (index < len) {
            auctions[index] = Auction(
                beasts[_beastId],
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
                    beasts[_beastId],
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
        beastToTamer[_beastId] = address(this);
        tamerBeastCount[msg.sender]--;
        emit BeastAddedToAuction(_beastId, msg.sender, _startPrice);
    }

    //puts up beast for extraction
    function auctionBeastExtract(
        uint256 _beastId,
        uint256 _price,
        uint32 _endTime
    ) external onlyOwner(_beastId) {
        require(_isReady(_beastId), "This beast is not yet ready");
        require(_endTime > block.timestamp, "This auction has no duration");
        //find earliest spot in auction list
        uint256 len = auctions.length;
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
        beasts[_beastId].readyTime = _endTime;
        emit BeastAddedForExtract(_beastId, msg.sender, _price);
    }

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

    //function to re collect monster after failed sale from either auction or extraction, or prior
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
            beastToTamer[_beastId] = auctions[_auctionNo].seller;
            tamerBeastCount[msg.sender]++;
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
            beasts[_beastId].readyTime = uint32(block.timestamp);
            emit RetrievedBeast(_beastId, msg.sender);
        }
    }

    //function to buy a beast from auction
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
        require(
            price < currency[msg.sender][0],
            "Insufficient funds [essence]"
        );
        currency[msg.sender][0] = currency[msg.sender][0] - price;
        currency[auction.seller][0] = currency[auction.seller][0] + price;
        //change owners
        beastToTamer[_beastId] = msg.sender;
        tamerBeastCount[msg.sender]++;
        //signal auction as ended
        auctions[_auctionNo].retrieved = true;
        //fire event
        emit BeastAuctioned(_beastId, msg.sender, price);
    }

    //function to buy a beast extraction from extraction auction
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
        require(
            extractAuction.price < currency[msg.sender][0],
            "Insufficient funds [essence]"
        );
        currency[msg.sender][0] =
            currency[msg.sender][0] -
            extractAuction.price;
        currency[extractAuction.seller][0] =
            currency[extractAuction.seller][0] +
            extractAuction.price;
        //change owner of extract
        extractToTamer[_beastId] = Extract(
            msg.sender,
            _beastId,
            uint32(block.timestamp + minRecoveryPeriod)
        );
        //put owners beast to recovery for a day
        _triggerRecoveryPeriod(_beastId, 1);
        //signal auction ended
        extractAuctions[_auctionNo].retrieved = true;
        //fire event
        emit BeastExtractAuctioned(_beastId, msg.sender, extractAuction.price);
    }

    //return extracts owned by msg.sender
    function getExtracts() external view returns (uint256[] memory) {
        uint256 len = beasts.length;
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
}
