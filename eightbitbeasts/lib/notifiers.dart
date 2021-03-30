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

class EthChangeNotifier extends ChangeNotifier {
  EthData data = EthData();
  Client httpClient;
  Web3Client ethClient;
  bool initiated = false;
  double gwei = 1;
  double gas = 50000;
  double extra = 20000;
  List<bool> selected = [];

  void init() async {
    if (initiated) {
      return;
    }
    initiated = true;
    data = new EthData();
    httpClient = new Client();
    ethClient = new Web3Client(
        "https://rinkeby.infura.io/v3/c0ba200103214c0b9b002e5591ab09f7",
        httpClient);

    await inventoryRefresh();
    await getMarketMonsters(10);
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
    sortInventory(inv);
    notifyListeners();
  }

  void sortInventory(List<dynamic> inv) {
    int l = inv[0].length;
    data.monsterList = [];
    data.incubating = [];
    data.ready = [];
    selected = [];
    for (int i = 0; i < l; i++) {
      data.monsterList.add(Monster(
          name: inv[0][i][0],
          id: inv[0][i][2],
          grade: double.parse(inv[0][i][8].toString()),
          stats: makeStats(inv[0][i][1]),
          dna: convert(inv[0][i][10]),
          wins: double.parse(inv[0][i][6].toString()),
          losses: double.parse(inv[0][i][7].toString()),
          readyTime: double.parse(inv[0][i][5].toString()),
          remaining: double.parse(inv[0][i][9].toString()),
          img: Image.asset("lib/assets/fox.png")));

      selected.add(false);
      print(double.parse(inv[0][i][5].toString()) -
          DateTime.now().millisecondsSinceEpoch / 1000);
      if (double.parse(inv[0][i][5].toString()) >
          DateTime.now().millisecondsSinceEpoch / 1000) {
        print(inv[0][i][0]);
        data.incubating.add(Monster(
            name: inv[0][i][0],
            id: inv[0][i][2],
            grade: double.parse(inv[0][i][8].toString()),
            stats: makeStats(inv[0][i][1]),
            dna: convert(inv[0][i][10]),
            wins: double.parse(inv[0][i][6].toString()),
            losses: double.parse(inv[0][i][7].toString()),
            readyTime: double.parse(inv[0][i][5].toString()),
            remaining: double.parse(inv[0][i][9].toString()),
            img: Image.asset("lib/assets/bee.png")));
      } else {
        data.ready.add(Monster(
            name: inv[0][i][0],
            id: inv[0][i][2],
            grade: double.parse(inv[0][i][8].toString()),
            stats: makeStats(inv[0][i][1]),
            dna: convert(inv[0][i][10]),
            wins: double.parse(inv[0][i][6].toString()),
            losses: double.parse(inv[0][i][7].toString()),
            readyTime: double.parse(inv[0][i][5].toString()),
            remaining: double.parse(inv[0][i][9].toString()),
            img: Image.asset("lib/assets/fox.png")));
      }
    }
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
    data.myPublicAddress = '0x' + bytesToHex(publicKeyToAddress(publicKey));
    notifyListeners();
    update();
  }

  Future<void> marketRefresh() async {
    await getMarketMonsters(10);
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
    List<dynamic> inv = await getInventory(data.myPublicAddress);
    sortInventory(inv);
    print(DateTime.now().millisecondsSinceEpoch / 1000);
    print(data.incubating);

    //List<dynamic> res = await getExtracts();
    //sortExtracts(res);
    await getCurrency(data.myPublicAddress);
    notifyListeners();
  }

  void sortExtracts(res) async {
    print('extracts:  ' + res.toString());
    int l = res.length;
    if (l == 0) {
      return;
    }
    data.myMonsterExtracts = [];
    for (int j = 0; j < l; j++) {
      if (res[0][j][2] < DateTime.now().millisecondsSinceEpoch / 1000) {
        continue;
      }
      Monster beast = await getBeast(res[0][j][1]);
      data.myMonsterExtracts.add(beast);
    }
  }

//#################################################
// refresh everything
//#################################################
  void update() async {
    await getCurrency(data.myPublicAddress);
    List<dynamic> inv = await getInventory(data.myPublicAddress);
    sortInventory(inv);
    await getMarketMonsters(10);
    //List<dynamic> res = await getExtracts();
    //sortExtracts(res);
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

  Future<void> getMarketMonsters(int limit) async {
    data.marketMonstersForAuction = [];
    data.marketMonstersForDonor = [];
    data.myMarketMonstersForAuction = [];
    data.myMarketMonstersForDonor = [];
    await getAuctions(limit);
    await getExtractAuctions(limit);
  }

  Future<void> getAuctions(int limit) async {
    List<dynamic> response = await query("getAuctions", [], 'market');
    //gets # of entries in each
    print(response);
    int n = limit - 10;
    while (n < limit && n < int.parse(response[0].toString())) {
      List<dynamic> res = await query("auctions", [BigInt.from(n)], 'market');
      //print(res);
      //print(data.myPublicAddress.toString().toLowerCase());
      if (data.myPublicAddress.toString().toLowerCase() ==
          res[1].toString().toLowerCase()) {
        data.myMarketMonstersForAuction.add(Auction(
            seller: res[1].toString(),
            startPrice: double.parse(res[2].toString()),
            endPrice: double.parse(res[3].toString()),
            startTime: double.parse(res[4].toString()),
            duration: double.parse((res[5] - res[4]).toString()),
            isMine: true,
            monster: Monster(
                name: res[0][0],
                id: res[0][2],
                grade: double.parse(res[0][8].toString()),
                stats: makeStats(res[0][1]),
                dna: convert(res[0][10]),
                wins: double.parse(res[0][6].toString()),
                losses: double.parse(res[0][7].toString()),
                readyTime: double.parse(res[0][5].toString()),
                remaining: double.parse(res[0][9].toString()),
                img: Image.asset("lib/assets/fox.png"))));
      } else {
        data.marketMonstersForAuction.add(Auction(
            seller: res[1].toString(),
            startPrice: double.parse(res[2].toString()),
            endPrice: double.parse(res[3].toString()),
            startTime: double.parse(res[4].toString()),
            duration: double.parse((res[5] - res[4]).toString()),
            isMine: false,
            monster: Monster(
                name: res[0][0],
                id: res[0][2],
                grade: double.parse(res[0][8].toString()),
                stats: makeStats(res[0][1]),
                dna: convert(res[0][10]),
                wins: double.parse(res[0][6].toString()),
                losses: double.parse(res[0][7].toString()),
                readyTime: double.parse(res[0][5].toString()),
                remaining: double.parse(res[0][9].toString()),
                img: Image.asset("lib/assets/fox.png"))));
      }
      n += 1;
    }
  }

  Future<void> getExtractAuctions(int limit) async {
    List<dynamic> response = await query("getAuctions", [], 'market');
    //gets # of entries in each
    int n = limit - 10;

    while (n < limit && n < int.parse(response[1].toString())) {
      List<dynamic> res =
          await query("extractAuctions", [BigInt.from(n)], 'market');
      if (data.myPublicAddress.toString().toLowerCase() ==
          res[1].toString().toLowerCase()) {
        print(data.myPublicAddress.toString().toLowerCase());
        Monster beast = await getBeast(res[0][1]);
        data.myMarketMonstersForDonor.add(Auction(
            seller: res[1].toString(),
            startPrice: double.parse(res[2].toString()),
            endPrice: double.parse(res[2].toString()),
            startTime: 0,
            duration: double.parse(res[3].toString()),
            isMine: true,
            monster: beast));
      } else {
        Monster beast = await getBeast(res[0][1]);
        data.marketMonstersForDonor.add(Auction(
            seller: res[1].toString(),
            startPrice: double.parse(res[2].toString()),
            endPrice: double.parse(res[2].toString()),
            startTime: 0,
            duration: double.parse(res[3].toString()),
            isMine: false,
            monster: beast));
      }
      n += 1;
    }
  }

  Future<List<dynamic>> getInventory(targetAddress) async {
    EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    List<dynamic> response =
        await query("getBeastsByTamer", [address], 'mother');
    return response;
  }

  Future<List<dynamic>> getExtracts() async {
    List<dynamic> response = await query("getExtracts", [], 'market');
    return response;
  }

  Future<Monster> getBeast(BigInt id) async {
    List<dynamic> res = await query("getBeast", [id], 'mother');
    Monster beast = Monster(
        name: res[0][0].toString(),
        id: res[0][2],
        grade: double.parse(res[0][8].toString()),
        stats: makeStats(res[0][1]),
        dna: convert(res[0][10]),
        wins: double.parse(res[0][6].toString()),
        losses: double.parse(res[0][7].toString()),
        readyTime: double.parse(res[0][5].toString()),
        remaining: double.parse(res[0][9].toString()),
        img: Image.asset("lib/assets/fox.png"));
    return beast;
  }

//Other functions to get stuffs like market monsters, and inventory.
  void openSelector(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
            color: Theme.of(context).accentColor,
            child: Column(
              children: [
                ListTile(title: Text("ready beasts")),
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 1,
                    crossAxisCount: 4,
                  ),
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, position) {
                    return Selector(context: context, position: position);
                  },
                  itemCount: data.ready.length,
                ),
                ElevatedButton(
                    onPressed: () async {
                      String x = await prepTransaction(context, 0);
                      if (x != null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(x)));
                        Navigator.pop(context);
                      }
                    },
                    child: Text("continue"))
              ],
            )));
  }

  bool isSelected(position) {
    return selected[position];
  }

  void changeSelected(position) {
    selected[position] = selected[position] ? false : true;
    notifyListeners();
  }

  Future<String> prepTransaction2(BuildContext context, type) async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text("transaction details"),
            children: [
              SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, 0);
                  },
                  child: Text("this")),
              SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, 1);
                  },
                  child: Text("that"))
            ],
          );
        })) {
      case 0:
        return 'this';
        break;
      case 1:
        return 'that';

        break;
    }
  }

  Future<String> prepTransaction(BuildContext context, type) async {
    switch (await Navigator.push(
        context,
        MaterialPageRoute<int>(
          builder: (BuildContext context) => FullScreenDialog(type: type),
          fullscreenDialog: true,
        ))) {
      case 0:
        return 'Transaction Cancelled';
        break;
      case 1:
        return 'Transaction Submitted';
        break;
    }
  }
}

class FullScreenDialog extends ConsumerWidget {
  FullScreenDialog({@required this.type});

  final type;

  Widget dialogContent(int type) {
    return Card(
        child: Container(
      child: Text('yo'),
    ));
  }

  @override
  build(BuildContext context, ScopedReader watch) {
    final data = watch(myEthDataProvider);
    return Scaffold(
        appBar: AppBar(
          title: Text('Transaction'),
        ),
        body: Center(
          child: Column(
            children: [
              dialogContent(type),
              TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Gas',
                    helperText:
                        'Excess gas is refunded. Recommend minimum 50,000',
                  )),
              Spacer(),
              Row(
                children: [
                  Spacer(),
                  ElevatedButton(
                      child: Text("cancel"),
                      onPressed: () {
                        Navigator.pop(context, 0);
                      }),
                  Container(width: 5),
                  ElevatedButton(
                      child: Text("Submit"),
                      onPressed: () {
                        Navigator.pop(context, 1);
                        //data.transact(type);
                      }),
                ],
              ),
              Container(height: 50),
            ],
          ),
        ));
  }
}

class Selector extends ConsumerWidget {
  Selector({@required this.context, @required this.position});
  final context;
  final position;

  @override
  build(BuildContext context, ScopedReader watch) {
    final info = watch(myEthDataProvider);

    return InkWell(
      splashColor: Colors.white,
      onTap: () {
        info.changeSelected(position);
      },
      child: Container(
        color: info.isSelected(position)
            ? Colors.red.withOpacity(0.8)
            : Colors.transparent,
        height: 50,
        width: 50,
        child: Stack(
          children: [
            Container(
              color: info.isSelected(position)
                  ? Color(0xfffef0d1)
                  : Colors.transparent,
            ),
            MonsterPicSmall(
              data: info.data.ready[position],
            ),
          ],
        ),
      ),
    );
  }
}
