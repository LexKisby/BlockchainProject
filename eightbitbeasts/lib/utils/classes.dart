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
