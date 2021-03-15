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
    List<dynamic> inv = await getInventory(data.myPublicAddress);
    await getCurrency(data.myPublicAddress);
    print(inv);
    int l = inv[0].length;
    data.monsterList = [];
    for (int i = 0; i < l; i++) {
      data.monsterList.add(Monster(
          name: inv[0][i][0],
          id: inv[0][i][2],
          grade: double.parse(inv[0][i][8].toString()),
          stats: makeStats(inv[0][i][1]),
          dna: convert(inv[0][i][10]),
          img: Image.asset("lib/assets/fox.png")));
    }
    notifyListeners();
  }

  String convert(List<dynamic> n) {
    String s = '';
    for (int x = 0; x < 22; x++) {
      s += n[x].toString();
    }
    return s;
  }

  String makeStats(List<dynamic> stats) {
    String s = '';
    for (int j = 0; j < stats.length; j++) {
      s += stats[j].toString().padLeft(3, '0');
    }
    return s;
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
    //await getCurrency(data.myPublicAddress);
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
    data.rubies = 0;
    data.essence = 0;
    data.marketMonstersForAuction = [];
    data.marketMonstersForDonor = [];
    data.myMarketMonstersForAuction = [];
    data.myMarketMonstersForDonor = [];
    data.monsterList = [];
    data.monsterImageList = [];
    data.myMonsterExtracts = [];
    data.incubating = [];
    //await getCurrency(data.myPublicAddress);
    //await getMyMonsters();
    //await getMarketMonsters();
    //await getBattleInfo();
    //await getLeaderBoards();
    notifyListeners();
    return;
  }

//#########################################################################################
  //Functions to load contract and query/submit to the blockchain
//#########################################################################################

  //Load contract
  Future<DeployedContract> loadContract(String type) async {
    String prepABI = contractAddresses[type][1];
    String contractAddress = contractAddresses[type][0];

    final contract = DeployedContract(ContractAbi.fromJson(prepABI, "contract"),
        EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  //general function to query contract
  Future<List<dynamic>> query(
      String functionName, List<dynamic> args, String type) async {
    final contract = await loadContract(type);
    final ethFunction = contract.function(functionName);
    final response = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    print('response recieved');
    return response;
  }

  //general function to transact with contract
  Future<String> submit(
      String functionName, List<dynamic> args, String type) async {
    final contract = await loadContract(type);
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

  Future<void> getCurrency(String targetAddress) async {
    EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    List<dynamic> responseE =
        await query("currency", [address, BigInt.from(0)], 'mother');
    List<dynamic> responseR =
        await query("currency", [address, BigInt.from(1)], 'mother');
    data.essence = double.parse(responseE[0].toString());
    data.rubies = double.parse(responseR[0].toString());
    data.hasCurrency = true;
  }

  Future<void> getMarketMonsters() async {
    List<dynamic> response = await query("getMarketMonsters", [], 'market');
    data.marketMonstersForAuction = response[0];
    data.marketMonstersForDonor = response[1];
  }

  Future<List<dynamic>> getInventory(targetAddress) async {
    EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    List<dynamic> response =
        await query("getBeastsByTamer", [address], 'mother');
    return response;
  }

//Other functions to get stuffs like market monsters, and inventory.

}
