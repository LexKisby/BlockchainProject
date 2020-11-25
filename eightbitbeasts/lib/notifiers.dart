part of page_classes;

class MyWalletChangeNotifier extends ChangeNotifier {
  MyWalletChangeNotifier([this.address = 0]);

  int address;

  void increment() {
    address++;
    notifyListeners();
  }
}

class EthData {
  List<Monster> monsterList;
  List<Image> monsterImageList;
  double rubies;
  double essence;
  List<Monster> marketMonstersForBreeding;
  List<Auction> marketMonstersForBuying;
  bool hasMonsterList;
  bool hasCurrency;
}

class EthChangeNotifier extends ChangeNotifier {
  EthData data;
  Client httpClient;
  Web3Client ethClient;

  void init() {
    httpClient = new Client();
    ethClient = new Web3Client("http://localhost:7545", httpClient);
    data.hasMonsterList = false;
    data.hasCurrency = false;
    return;
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString("assets/abi/abi.json");
    String contractAddress = "0x0b1B455acfbB4476c879c96EcDF315913FD22518";

    final contract = DeployedContract(ContractAbi.fromJson(abi, "test"),
        EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  //general function to query contract
  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final response = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    return response;
  }

  //general function to transact with contract
  Future<String> submit(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    EthPrivateKey credentials = EthPrivateKey.fromHex('boo');
    Transaction transaction = Transaction.callContract(
        contract: contract, function: ethFunction, parameters: args);
    final response = await ethClient.sendTransaction(credentials, transaction,
        fetchChainIdFromNetworkId: true);
    return response;
  }

  //Ingame currency, non erc20 token, called 'gold'
  Future<void> getRubyBalance(String targetAddress) async {
    EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    List<dynamic> response = await query("getRubyBalanceFrom", [address]);
    data.rubies = response[0];
  }

  //ingame currency, is an erc 20 token, rare, called "Essence"
  Future<void> getEssenceBalance(String targetAddress) async {
    EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    List<dynamic> response = await query("getEssenceBalanceFrom", [address]);
    data.essence = response[0];
  }

  Future<void> getCurrency(String targetAddress) async {
    await getEssenceBalance(targetAddress);
    await getRubyBalance(targetAddress);
    data.hasCurrency = true;
  }
}

class MyMonstersChangeNotifier extends ChangeNotifier {
  MyMonstersChangeNotifier([this.info]);

  int n;
  List<Monster> info;
  List<Image> imgs;
  //need function to retrieve info from blockchain

  //need function to retrieve image for each monster
  void getInventory() {}

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
        grade: 1,
        stats: "001004003005003006012003008",
        dna: 23842938));
    info.add(Monster(
      name: "MATT",
      id: 0,
      grade: 3,
      stats: "999999999999999999999999999",
      dna: 390473,
    ));
    info.add(Monster(
      name: "VELINA",
      id: 0,
      grade: 2,
      stats: "999999999999999999999999999",
      dna: 390473,
    ));
    info.add(Monster(
      name: "MATT",
      id: 0,
      grade: 5,
      stats: "999999999999999999999999999",
      dna: 390473,
    ));
    info.add(Monster(
      name: "ALEX",
      id: 0,
      grade: 1,
      stats: "999999969999979999999999999",
      dna: 390473,
    ));
    info.add(Monster(
      name: "MATT",
      id: 0,
      grade: 7,
      stats: "999999999999999999999999999",
      dna: 390473,
    ));
    info.add(Monster(
      name: "MATT",
      id: 0,
      grade: 8,
      stats: "999999999999999999999999999",
      dna: 390473,
    ));
    info.add(Monster(
      name: "MATT",
      id: 0,
      grade: 9,
      stats: "999999999999999999999999999",
      dna: 390473,
    ));
    info.add(Monster(
      name: "MATT",
      id: 0,
      grade: 0,
      stats: "999999999999999999999999999",
      dna: 390473,
    ));
    imgs.addAll([
      Image.asset("lib/assets/fox.png"),
      Image.asset("lib/assets/fox.png"),
      Image.asset("lib/assets/fox.png")
    ]);
    notifyListeners();
  }
}
