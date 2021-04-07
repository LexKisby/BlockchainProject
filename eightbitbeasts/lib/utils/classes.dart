part of page_classes;

class Monster {
  Monster({
    @required this.name,
    @required this.id,
    @required this.grade,
    @required this.stats,
    @required this.dna,
    @required this.wins,
    @required this.losses,
    @required this.readyTime,
    @required this.remaining,
    @required this.img,
  });

  String name;
  BigInt id;
  double grade;
  String stats;
  String dna;
  double wins;
  double losses;
  double readyTime;
  double remaining;
  Image img;
}

class Auction {
  Monster monster;
  double startTime;
  double duration;
  double startPrice;
  double endPrice;
  String seller;
  int id;

  bool isMine;
  bool retrieved;

  Auction({
    @required this.id,
    @required this.monster,
    @required this.startTime,
    @required this.duration,
    @required this.startPrice,
    @required this.endPrice,
    @required this.seller,
    @required this.isMine,
  });
}

class EthData {
  List<Monster> monsterList = []; //Monsters in my inventory
  List<Image> monsterImageList = []; //Images for the monsters in my inventory
  List<Image> auctionMonsterImages = []; //Images for the monsters for auction
  List<Image> donorMonsterImages = []; // Imahes for the monsters for extraction
  double rubies = 0; //number of rubies in possession
  double essence = 0; // number of essence in possession
  List<Auction> marketMonstersForDonor = []; //monsters for sale
  List<Auction> marketMonstersForAuction = []; // monsters for extraction
  List<Auction> myMarketMonstersForAuction =
      []; //My monsters in the market for Auction
  List<Auction> myMarketMonstersForDonor =
      []; //My monsters in the market for Donor
  List<Monster> myMonsterExtracts = []; // Monster extracts in user possesion
  List<Monster> incubating = []; //Monsters just born
  List<Monster> recovering = []; //Monsters that are not in the ready state
  List<Monster> ready = []; // Monsters that are in the ready state

  String myPublicAddress = myAddress;
  String myPrivateKey = privateKey;
  bool hasMonsterList = false;
  bool hasCurrency = false;
}
