part of page_classes;

class Monster {
  Monster({
    this.name,
    this.id,
    this.grade,
    this.stats,
    this.dna,
    this.img,
  });

  String name;
  int id;
  double grade;
  String stats;
  int dna;
  Image img;
}

class Auction {
  Monster monster;
  double startTime;
  double duration;
  double startPrice;
  double endPrice;
  String seller;

  bool isMine;

  Auction({
    this.monster,
    this.startTime,
    this.duration,
    this.startPrice,
    this.endPrice,
    this.seller,
    this.isMine,
  });
}

class EthData {
  List<Monster> monsterList; //Monsters in my inventory
  List<Image> monsterImageList; //Images for the monsters in my inventory
  List<Image> auctionMonsterImages; //Images for the monsters for auction
  List<Image> donorMonsterImages; // Imahes for the monsters for extraction
  double rubies; //number of rubies in possession
  double essence; // number of essence in possession
  List<Auction> marketMonstersForDonor; //monsters for sale
  List<Auction> marketMonstersForAuction; // monsters for extraction
  List<Auction>
      myMarketMonstersForAuction; //My monsters in the market for Auction
  List<Auction> myMarketMonstersForDonor; //My monsters in the market for Donor

  String myPublicAddress;
  String myPrivateKey;
  bool hasMonsterList = false;
  bool hasCurrency = false;
}
