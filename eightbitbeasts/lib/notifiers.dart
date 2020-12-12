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
    return RaisedButton(
      onPressed: () {
        update.update();
      },
      child: Icon(Icons.refresh_sharp),
      color: Theme.of(context).accentColor,
    );
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
    data.myMarketMonstersForAuction = [];
    data.myMarketMonstersForDonor = [];
    data.monsterList = [];
    data.monsterImageList = [];
    data.myMonsterExtracts = [];
    data.myPublicAddress = myAddress;
    data.myPrivateKey = myPrivateKey;
    data.incubating = [];

    await getCurrency(data.myPublicAddress);
    data.hasCurrency = true;

    notifyListeners();
    return;
  }

//###############################################
// mini update functions
//###############################################
  Future<void> inventoryRefresh() async {
    //await getMyMonsters();
    await getCurrency(data.myPublicAddress);

    await testFunction();
    notifyListeners();
  }

  void updateCredentials(value) {
    data.myPrivateKey = value;
    var byteString = hexToBytes(value);
    var publicKey = privateKeyBytesToPublic(byteString);
    data.myPublicAddress = bytesToHex(publicKeyToAddress(publicKey));
    notifyListeners();
    update();
  }

  Future<void> marketRefresh() async {
    //await getMarketMonsters();
    print("refreshed monsters");
    await getCurrency(data.myPublicAddress);
    notifyListeners();
  }

  Future<void> battleRefresh() async {
    //await getBattleInfo();
    notifyListeners();
  }

  Future<void> leaderBoardsRefresh() async {
    //await getLeaderBoards();
    notifyListeners();
  }

  Future<void> labRefresh() async {
    //await getLabInfo();
    notifyListeners();
  }

//#################################################
// refresh everything
//#################################################
  void update() async {
    data.marketMonstersForAuction = [];
    data.marketMonstersForDonor = [];
    data.myMarketMonstersForAuction = [];
    data.myMarketMonstersForDonor = [];
    data.monsterList = [];
    data.monsterImageList = [];
    data.myMonsterExtracts = [];
    data.incubating = [];
    await getCurrency(data.myPublicAddress);
    //await getMyMonsters();
    //await getMarketMonsters();
    //await getBattleInfo();
    //await getLeaderBoards();

    await testFunction();

    notifyListeners();
    return;
  }

  Future<void> testFunction() async {
    data.incubating.add(Monster(
        name: "MYSTERY1",
        id: 37,
        grade: 8,
        stats: "???????????????????????????",
        dna: 82938202303211,
        img: Image.asset("lib/assets/mysteryBox.png")));
    data.incubating.add(Monster(
        name: "MYSTERY2",
        id: 38,
        grade: 7,
        stats: "???????????????????????????",
        dna: 82938202303211,
        img: Image.asset("lib/assets/mysteryBox.png")));
    data.incubating.add(Monster(
        name: "MYSTERY3",
        id: 39,
        grade: 3,
        stats: "???????????????????????????",
        dna: 82938202303211,
        img: Image.asset("lib/assets/mysteryBox.png")));
    data.marketMonstersForAuction.add(Auction(
      monster: Monster(
        name: 'MOBIUS',
        id: 1,
        grade: 1,
        stats: "000003300000044000000000000",
        dna: 17374827,
        img: Image.asset("lib/assets/bigRuby.png"),
      ),
      startTime: 1607650841,
      duration: 500000,
      startPrice: 10000,
      endPrice: 10,
      seller: "yo mama",
      isMine: false,
    ));

    data.marketMonstersForDonor.add(Auction(
      monster: Monster(
        name: 'FOBIUS',
        id: 2,
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
      isMine: false,
    ));

    data.myMarketMonstersForAuction.add(Auction(
      monster: Monster(
        name: 'TOBIUS',
        id: 3,
        grade: 5,
        stats: "499900000000380460000000100",
        dna: 17374827,
        img: Image.asset("lib/assets/fox.png"),
      ),
      startTime: 1607650841,
      duration: 5000,
      startPrice: 10000,
      endPrice: 10,
      seller: "yo mama",
      isMine: true,
    ));

    data.monsterList.add(Monster(
      name: 'MOBIUS',
      id: 1,
      grade: 1,
      stats: "000000000000000000000000000",
      dna: 17374827,
    ));
    data.monsterList.add(Monster(
        name: "0123456",
        id: 2,
        grade: 1,
        stats: "001004003005003006012003008",
        dna: 23842938));
    data.monsterList.add(Monster(
      name: "MATT",
      id: 3,
      grade: 3,
      stats: "999999999999999999999999999",
      dna: 390473,
    ));
    data.monsterList.add(Monster(
      name: "VELINA",
      id: 4,
      grade: 2,
      stats: "999999999999999999999999999",
      dna: 390473,
    ));
    data.monsterList.add(Monster(
      name: "MATT",
      id: 5,
      grade: 5,
      stats: "999999999999999999999999999",
      dna: 390473,
    ));
    data.myMonsterExtracts.add(Monster(
        name: "FRANK",
        id: 6,
        grade: 2,
        stats: "311113611357362265020520209",
        dna: 583938540,
        img: Image.asset("lib/assets/fox.png")));
    data.myMonsterExtracts.add(Monster(
        name: "JANGO",
        id: 7,
        grade: 7,
        stats: "311113611357362265020520209",
        dna: 583938540,
        img: Image.asset("lib/assets/bee.png")));
    data.myMonsterExtracts.add(Monster(
        name: "FRANK",
        id: 8,
        grade: 5,
        stats: "311113611357362265020520209",
        dna: 583938540,
        img: Image.asset("lib/assets/bigRuby.png")));

    data.monsterImageList.addAll([
      Image.asset("lib/assets/bigRuby.png"),
      Image.asset("lib/assets/bigEssence.png"),
      Image.asset("lib/assets/fox.png"),
      Image.asset("lib/assets/fox.png"),
      Image.asset("lib/assets/fox.png"),
    ]);

    print('done');
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
    final response = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    print('response recieved');
    return response;
  }

  //general function to transact with contract
  Future<String> submit(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    print('loaded function from contract');
    EthPrivateKey credentials = EthPrivateKey.fromHex(data.myPrivateKey);
    print("privateKeyLoaded");
    Transaction transaction = Transaction.callContract(
        contract: contract, function: ethFunction, parameters: args);
    print("transaction Loaded");
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

  Future<void> getMarketMonsters() async {
    List<dynamic> response = await query("getMarketMonsters", []);
    data.marketMonstersForAuction = response[0];
    data.marketMonstersForDonor = response[1];
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
