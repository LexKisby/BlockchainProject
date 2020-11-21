part of page_classes;

class MyWalletChangeNotifier extends ChangeNotifier {
  MyWalletChangeNotifier([this.address = 0]);

  int address;

  void increment() {
    address++;
    notifyListeners();
  }
}

class MyMonstersChangeNotifier extends ChangeNotifier {
  MyMonstersChangeNotifier([this.info]);

  int n;
  List<Monster> info;
  List<Image> imgs;
  //need function to retrieve info from blockchain

  //need function to retrieve image for each monster

  //fake list to test provider:

  void update() {
    info = [];
    imgs = [];
    info.add(Monster(
      name: 'MOBIUS',
      id: 1,
      grade: 1,
      stats: "000000000000000000000000000",
      dna: 17374827,
    ));
    info.add(Monster(
        name: "0123456",
        id: 2,
        grade: 3,
        stats: "001004003005003006012003008",
        dna: 23842938));
    imgs.addAll(
        [Image.asset("lib/assets/fox.png"), Image.asset("lib/assets/cat.png")]);
    notifyListeners();
  }
}
