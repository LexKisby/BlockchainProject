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
  MyMonstersChangeNotifier();

  List<Monster> info;
  //need function to retrieve info from blockchain

  //need function to retrieve image for each monster

  void update() {
    notifyListeners();
  }
}
