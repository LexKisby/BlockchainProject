part of page_classes;

class InitWidget extends ConsumerWidget {
  build(BuildContext context, ScopedReader watch) {
    final update = watch(myEthDataProvider);
    update.init();
    return Container();
  }
}

class UpdateWidget extends ConsumerWidget {
  build(BuildContext context, ScopedReader watch) {
    final update = watch(myEthDataProvider);
    return FloatingActionButton(onPressed: () {
      update.update();
    });
  }
}

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
  List<Image> auctionMonsterImages;
  List<Image> donorMonsterImages;
  double rubies;
  double essence;
  List<Auction> marketMonstersForDonor;
  List<Auction> marketMonstersForAuction;
  bool hasMonsterList = false;
  bool hasCurrency = false;
}

class EthChangeNotifier extends ChangeNotifier {
  EthData data;
  Client httpClient;
  Web3Client ethClient;
  bool initiated;

  void init() async {
    initiated ??= false;
    if (initiated) {
      return;
    }
    initiated = true;
    data = new EthData();
    httpClient = new Client();
    ethClient = new Web3Client(
        "https://rinkeby.infura.io/v3/c0ba200103214c0b9b002e5591ab09f7",
        httpClient);
    data.hasMonsterList = false;
    data.hasCurrency = false;
    data.rubies = 0;
    data.essence = 0;
    data.monsterList = [];
    data.marketMonstersForAuction = [];
    data.marketMonstersForDonor = [];
    await getCurrency(myAddress);
    data.hasCurrency = true;

    notifyListeners();
    return;
  }

  void update() async {
    print('updating');
    //test the contract on the block rn
    print("testing");
    await testFunction();
    await getCurrency(myAddress);

    //other junk
    data.marketMonstersForAuction.add(Auction(
      monster: Monster(
        name: 'MOBIUS',
        id: 1,
        grade: 1,
        stats: "000000000000000000000000000",
        dna: 17374827,
        img: Image.asset("lib/assets/fox.png"),
      ),
      startTime: 1607650841,
      duration: 500000,
      startPrice: 10000,
      endPrice: 10,
      seller: "yo mama",
    ));

    data.marketMonstersForDonor.add(Auction(
      monster: Monster(
        name: 'FOBIUS',
        id: 1,
        grade: 2,
        stats: "000000000000000000000000000",
        dna: 17374827,
        img: Image.asset("lib/assets/fox.png"),
      ),
      startTime: 1607650841,
      duration: 5000,
      startPrice: 10000,
      endPrice: 10,
      seller: "yo mama",
    ));

    data.marketMonstersForAuction.add(Auction(
      monster: Monster(
        name: 'TOBIUS',
        id: 1,
        grade: 5,
        stats: "000000000000000000000000000",
        dna: 17374827,
        img: Image.asset("lib/assets/fox.png"),
      ),
      startTime: 1607650841,
      duration: 5000,
      startPrice: 10000,
      endPrice: 10,
      seller: "yo mama",
    ));

    print('done');
    notifyListeners();
    return;
  }

//#########################################################################################
  //Functions to load contract and query/submit to the blockchain
//#########################################################################################

  //Load contract
  Future<DeployedContract> loadContract() async {
    String prepABI = abi_raw;
    //String abi = await rootBundle.loadString(prepABI);
    String contractAddress = contract_address;

    final contract = DeployedContract(ContractAbi.fromJson(prepABI, "test"),
        EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  //general function to query contract
  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    print('sending query');
    final response = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    print('response recieved');
    return response;
  }

  //general function to transact with contract
  Future<String> submit(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    print('contract Loaded');
    final ethFunction = contract.function(functionName);
    print('loaded function from contract');
    EthPrivateKey credentials = EthPrivateKey.fromHex(
        'ca33eca722358473bd0a8a2db70ffdedf44b4cd1ed3ae4f1981759dda149de7c');
    Transaction transaction = Transaction.callContract(
        contract: contract, function: ethFunction, parameters: args);
    final response = await ethClient.sendTransaction(credentials, transaction,
        fetchChainIdFromNetworkId: true);
    print('recieved submit response');
    return response;
  }

//##############################################################################################
  //Ingame currency, non erc20 token, called 'ruby'
  Future<void> getRubyBalance(String targetAddress) async {
    EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    List<dynamic> response = await query("getRubyBalance", [address]);
    data.rubies = double.parse(response[0].toString());
  }

  //ingame currency, is an erc 20 token, rare, called "Essence"
  Future<void> getEssenceBalance(String targetAddress) async {
    EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    List<dynamic> response = await query("getEssenceBalance", [address]);
    data.essence = double.parse(response[0].toString());
  }

  Future<void> getCurrency(String targetAddress) async {
    await getEssenceBalance(targetAddress);
    await getRubyBalance(targetAddress);
    data.hasCurrency = true;
  }

  Future<void> testFunction() async {
    List<dynamic> response1 = await query("retrieve", []);
    print("retrieve value:  " + response1[0].toString());
    EthereumAddress address = EthereumAddress.fromHex(myAddress);
    List<dynamic> response3 = await query("getRubyBalance", [address]);
    print("rubies:    " + response3[0].toString());
    //String response2 = await submit("setEssenceBalance", [20]);
  }
//Other functions to get stuffs like market monsters, and inventory.

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
      Image.asset("lib/assets/abi/square.jpg"),
      Image.asset("lib/assets/fox.png"),
      Image.asset("lib/assets/fox.png")
    ]);
    notifyListeners();
  }
}
