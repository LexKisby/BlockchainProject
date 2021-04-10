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
    return ElevatedButton(
      onPressed: () {
        update.update();
      },
      child: Icon(Icons.refresh_sharp),
      //color: Theme.of(context).accentColor,
    );
  }
}

class EthChangeNotifier extends ChangeNotifier {
  EthData data = EthData();
  Client httpClient;
  Web3Client ethClient;
  bool initiated = false;
  double gasPriceInWei = 1000000000;
  double gas = 1000000;
  double extra = 20000;
  double total = 1000000000000000;
  List<bool> selectedBoolMask = [];

  double etherBalance = 0;

  List<dynamic> arguments = [];
  List<dynamic> selectedMonsters = [];
  List<dynamic> selectedAuctions = [];

  List<String> transactionList = [];
  List<bool> transactionSuccess = [];

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
    selectedBoolMask = [];
    //print(inv);
    for (int i = 0; i < l; i++) {
      data.monsterList.add(Monster(
          name: inv[0][i][0],
          id: inv[0][i][2],
          lvl: inv[0][i][3],
          xp: inv[0][i][4],
          grade: double.parse(inv[0][i][8].toString()),
          stats: makeStats(inv[0][i][1]),
          dna: convert(inv[0][i][10]),
          wins: double.parse(inv[0][i][6].toString()),
          losses: double.parse(inv[0][i][7].toString()),
          readyTime: double.parse(inv[0][i][5].toString()),
          remaining: double.parse(inv[0][i][9].toString()),
          img: getImageFromDna(inv[0][i][10].toString())));

      selectedBoolMask.add(false);
      //print(double.parse(inv[0][i][5].toString()) -
      //  DateTime.now().millisecondsSinceEpoch / 1000);
      if (double.parse(inv[0][i][5].toString()) >
          DateTime.now().millisecondsSinceEpoch / 1000) {
        //print(inv[0][i][0]);
        data.incubating.add(Monster(
            name: inv[0][i][0],
            id: inv[0][i][2],
            lvl: inv[0][i][3],
            xp: inv[0][i][4],
            grade: double.parse(inv[0][i][8].toString()),
            stats: makeStats(inv[0][i][1]),
            dna: convert(inv[0][i][10]),
            wins: double.parse(inv[0][i][6].toString()),
            losses: double.parse(inv[0][i][7].toString()),
            readyTime: double.parse(inv[0][i][5].toString()),
            remaining: double.parse(inv[0][i][9].toString()),
            img: getImageFromDna(inv[0][i][10].toString())));
      } else {
        data.ready.add(Monster(
            name: inv[0][i][0],
            id: inv[0][i][2],
            lvl: inv[0][i][3],
            xp: inv[0][i][4],
            grade: double.parse(inv[0][i][8].toString()),
            stats: makeStats(inv[0][i][1]),
            dna: convert(inv[0][i][10]),
            wins: double.parse(inv[0][i][6].toString()),
            losses: double.parse(inv[0][i][7].toString()),
            readyTime: double.parse(inv[0][i][5].toString()),
            remaining: double.parse(inv[0][i][9].toString()),
            img: getImageFromDna(inv[0][i][10].toString())));
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

  Future<void> updateTransactions() async {
    transactionSuccess = [];
    for (int i = 0; i < transactionList.length; i++) {
      TransactionInformation info =
          await ethClient.getTransactionByHash(transactionList[i]);
      print(info);
      if (info.transactionIndex == null) {
        transactionSuccess.add(null);
        continue;
      }
      TransactionReceipt receipt =
          await ethClient.getTransactionReceipt(transactionList[i]);
      print(receipt);
      if (receipt.status == true) {
        transactionSuccess.add(true);
      } else {
        if (receipt.status == false) {
          transactionSuccess.add(false);
        } else {
          transactionSuccess.add(null);
        }
      }
    }
    notifyListeners();
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

  Future<void> labRefresh() async {
    List<dynamic> inv = await getInventory(data.myPublicAddress);
    sortInventory(inv);
    //print(DateTime.now().millisecondsSinceEpoch / 1000);
    //print(data.incubating);

    //List<dynamic> res = await getExtracts();
    //print(res);
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
    notifyListeners();
    return;
  }

  //#################################################
  //getpics
  //#################################################
  //
  Image getImageFromDna(String dna) {
    String species = dna[1];

    String path = 'lib/assets/' + species + '.png';
    return Image.asset(path);
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
    //print('response recieved');
    return response;
  }

  //general function to transact with contract
  Future<String> submit(
      String functionName, List<dynamic> args, String type) async {
    final contract = await loadContract(type);
    final ethFunction = contract.function(functionName);
    //print('loaded function from contract');
    EthPrivateKey credentials = EthPrivateKey.fromHex(data.myPrivateKey);
    //print("privateKeyLoaded");
    Transaction transaction = Transaction.callContract(
        contract: contract,
        function: ethFunction,
        parameters: args,
        maxGas: gas.toInt(),
        gasPrice: EtherAmount.fromUnitAndValue(
            EtherUnit.wei, BigInt.from(gasPriceInWei)));
    print("transaction Loaded");
    final response = await ethClient.sendTransaction(credentials, transaction,
        fetchChainIdFromNetworkId: true);
    print('recieved submit response');
    return response;
  }

  Future<void> getEtherBalance() async {
    EthereumAddress address = EthereumAddress.fromHex(myAddress);
    EtherAmount amount = await ethClient.getBalance(address);
    print(amount.getInWei);
    etherBalance = double.parse(amount.getInWei.toString());
    notifyListeners();
  }

  Future<void> getGasPrice() async {
    EtherAmount amount = await ethClient.getGasPrice();
    gasPriceInWei = double.parse(amount.getInWei.toString());
    total = gasPriceInWei * gas;
    notifyListeners();
    //print(gasPriceInWei);
  }

  Future<void> createTransaction(type) async {
    //print(type);
    switch (type) {
      case 0:
        //Retrieval of beast from auction
        //make arguments [beastId, auction No, _type]
        BigInt beastId = selectedMonsters[0].id;
        BigInt auctionId = BigInt.from(selectedAuctions[0].id);
        print([beastId, auctionId]);
        arguments = [beastId, auctionId, BigInt.from(1)];
        String res = await submit('retrieve', arguments, 'market');
        transactionList.add(res);
        transactionSuccess.add(null);
        //clean selected Monsters
        selectedMonsters = [];
        selectedBoolMask = List<bool>.filled(data.ready.length, false);
        selectedAuctions = [];
        return;
        break;
      case 1:
        //make arguments [beastId, auction No, _type]
        BigInt beastId = selectedMonsters[0].id;
        BigInt auctionId = BigInt.from(selectedAuctions[0].id);

        arguments = [beastId, auctionId, BigInt.from(2)];
        print(arguments);
        String res = await submit('retrieve', arguments, 'market');
        transactionList.add(res);
        transactionSuccess.add(null);

        selectedMonsters = [];
        selectedBoolMask = List<bool>.filled(data.ready.length, false);

        selectedAuctions = [];
        return;
        break;
      case 2:
        //make arguments [beastId, auctionNo]
        BigInt beastId = selectedMonsters[0].id;
        BigInt auctionId = BigInt.from(selectedAuctions[0].id);
        print([beastId, auctionId]);
        arguments = [beastId, auctionId];
        String res = await submit('buyBeastFromAuction', arguments, 'market');
        transactionList.add(res);
        transactionSuccess.add(null);

        selectedMonsters = [];
        selectedBoolMask = List<bool>.filled(data.ready.length, false);

        selectedAuctions = [];
        return;
        break;
      case 3:
        //mke Arguments [beastId, auctionNo]
        BigInt beastId = selectedMonsters[0].id;
        BigInt auctionId = BigInt.from(selectedAuctions[0]);
        arguments = [beastId, auctionId];
        print([beastId, auctionId]);
        String res = await submit('buyExtractFromAuction', arguments, 'market');
        transactionList.add(res);
        transactionSuccess.add(null);

        selectedMonsters = [];
        selectedBoolMask = List<bool>.filled(data.ready.length, false);

        selectedAuctions = [];
        return;
        break;
      case 4:
        //make arguments [beastId, startPrice, endPrice, endTime]
        //rest handled by input form field
        BigInt beastId = selectedMonsters[0].id;
        arguments[0] = beastId;
        print(arguments);
        String res = await submit('auctionBeast', arguments, 'market');
        transactionList.add(res);
        transactionSuccess.add(null);
        //
        selectedMonsters = [];
        selectedBoolMask = List<bool>.filled(data.ready.length, false);

        return;
        break;
      case 5:
        //make arguments [beastId, price, endTime]
        BigInt beastId = selectedMonsters[0].id;
        arguments[0] = beastId;
        print(arguments);
        String res = await submit('auctionBeastExtract', arguments, 'market');
        transactionList.add(res);
        transactionSuccess.add(null);

        selectedMonsters = [];
        selectedBoolMask = List<bool>.filled(data.ready.length, false);
        return;
        break;
      case 6:
        //make arguments [primaryId, secondaryId, name]
        BigInt primaryId = selectedMonsters[0].id;
        BigInt secondaryId = selectedMonsters[1].id;
        arguments[0] = primaryId;
        arguments[1] = secondaryId;
        print(arguments);
        //print(selectedMonsters[0].remaining);
        //print(selectedMonsters[1].remaining);
        String res = await submit('BeastFusionSwitch', arguments, 'fusion');
        transactionList.add(res);
        transactionSuccess.add(null);

        selectedMonsters = [];
        selectedBoolMask = List<bool>.filled(data.ready.length, false);
        return;
        break;
      case 7:
        //make arguments [beastId]
        BigInt beastId = selectedMonsters[0].id;
        arguments = [beastId];
        print(arguments);
        String res = await submit('levelUp', arguments, 'mother');
        transactionList.add(res);
        transactionSuccess.add(null);

        selectedMonsters = [];
        selectedBoolMask = List<bool>.filled(data.ready.length, false);
        return;
        break;
    }
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
    //print(response);
    int n = limit - 10;
    while (n < limit && n < int.parse(response[0].toString())) {
      List<dynamic> res = await query("auctions", [BigInt.from(n)], 'market');
      print(res);
      //print(data.myPublicAddress.toString().toLowerCase());
      if (res[6]) {
        n += 1;
        continue;
      }
      if (data.myPublicAddress.toString().toLowerCase() ==
          res[1].toString().toLowerCase()) {
        data.myMarketMonstersForAuction.add(Auction(
            id: n,
            seller: res[1].toString(),
            startPrice: double.parse(res[2].toString()),
            endPrice: double.parse(res[3].toString()),
            startTime: double.parse(res[4].toString()),
            duration: double.parse((res[5] - res[4]).toString()),
            isMine: true,
            monster: Monster(
                name: res[0][0],
                id: res[0][2],
                lvl: res[0][3],
                xp: res[0][4],
                grade: double.parse(res[0][8].toString()),
                stats: makeStats(res[0][1]),
                dna: convert(res[0][10]),
                wins: double.parse(res[0][6].toString()),
                losses: double.parse(res[0][7].toString()),
                readyTime: double.parse(res[0][5].toString()),
                remaining: double.parse(res[0][9].toString()),
                img: getImageFromDna(res[0][10].toString()))));
      } else {
        data.marketMonstersForAuction.add(Auction(
            id: n,
            seller: res[1].toString(),
            startPrice: double.parse(res[2].toString()),
            endPrice: double.parse(res[3].toString()),
            startTime: double.parse(res[4].toString()),
            duration: double.parse((res[5] - res[4]).toString()),
            isMine: false,
            monster: Monster(
                name: res[0][0],
                id: res[0][2],
                lvl: res[0][3],
                xp: res[0][4],
                grade: double.parse(res[0][8].toString()),
                stats: makeStats(res[0][1]),
                dna: convert(res[0][10]),
                wins: double.parse(res[0][6].toString()),
                losses: double.parse(res[0][7].toString()),
                readyTime: double.parse(res[0][5].toString()),
                remaining: double.parse(res[0][9].toString()),
                img: getImageFromDna(res[0][10].toString()))));
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
      print(res);
      if (res[4]) {
        n += 1;
        continue;
      }

      if (data.myPublicAddress.toString().toLowerCase() ==
          res[1].toString().toLowerCase()) {
        //print(data.myPublicAddress.toString().toLowerCase());
        Monster beast = await getBeast(res[0][1]);
        data.myMarketMonstersForDonor.add(Auction(
            id: n,
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
            id: n,
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
        lvl: res[0][3],
        xp: res[0][4],
        grade: double.parse(res[0][8].toString()),
        stats: makeStats(res[0][1]),
        dna: convert(res[0][10]),
        wins: double.parse(res[0][6].toString()),
        losses: double.parse(res[0][7].toString()),
        readyTime: double.parse(res[0][5].toString()),
        remaining: double.parse(res[0][9].toString()),
        img: getImageFromDna(res[0][10].toString()));
    return beast;
  }

  int requiredMonsters(type) {
    if (type == 6) {
      return 2;
    }
    return 1;
  }

  void clearSelected() {
    selectedMonsters = [];
    selectedBoolMask = List<bool>.filled(data.ready.length, false);
    notifyListeners();
  }

//Other functions to get stuffs like market monsters, and inventory.
  void openSelector(BuildContext context, type) {
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
            color: Theme.of(context).accentColor,
            child: Column(
              children: [
                ListTile(
                    title: Text("ready beasts"),
                    subtitle: SelectorSubtitle(type: type),
                    trailing: ElevatedButton(
                        onPressed: () {
                          clearSelected();
                        },
                        child: Text('clear'))),
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
                      if (selectedMonsters.length == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('None selected')));
                        Navigator.pop(context);
                        return;
                      }
                      if (selectedMonsters.length != requiredMonsters(type)) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Please select [' +
                                requiredMonsters(type).toString() +
                                '] beasts')));
                        Navigator.pop(context);
                        return;
                      }
                      await getEtherBalance();
                      getGasPrice();
                      String x = await prepTransaction(context, type);
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
    return selectedBoolMask[position];
  }

  void changeSelected(position) {
    selectedBoolMask[position] = selectedBoolMask[position] ? false : true;
    selectedBoolMask[position]
        ? selectedMonsters.add(data.ready[position])
        : selectedMonsters.remove(data.ready[position]);
    notifyListeners();
  }

  Future<String> prepTransaction(BuildContext context, type) async {
    switch (await Navigator.push(
        context,
        MaterialPageRoute<int>(
          builder: (BuildContext context) => FullScreenDialog(type: type),
          fullscreenDialog: true,
        ))) {
      case 0:
        selectedAuctions = [];
        return 'Transaction Cancelled';

        break;
      case 1:
        return 'Transaction Submitted';
        break;
    }
    selectedAuctions = [];
    return 'Transaction Cancelled';
  }

  void changeGas(n) {
    gas = n;
    total = gasPriceInWei * gas;
    notifyListeners();
  }

  void changePrice(n) {
    gasPriceInWei = n * 1000000000;
    total = gasPriceInWei * gas;
    notifyListeners();
  }
}

class SelectorSubtitle extends ConsumerWidget {
  SelectorSubtitle({@required this.type});

  final type;

  @override
  build(BuildContext context, ScopedReader watch) {
    final info = watch(myEthDataProvider);
    return Text(
        'selected:  ' +
            info.selectedMonsters.length.toString() +
            ' / ' +
            info.requiredMonsters(type).toString(),
        style: TextStyle(fontSize: 12));
  }
}

class FullScreenDialog extends ConsumerWidget {
  FullScreenDialog({@required this.type});

  final type;

  Widget dialogContent(int type, beasts) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text('details'),
          Container(height: 10),
          Row(
            children: [
              Expanded(child: asset(type, beasts)),
              Divider(),
              Expanded(child: text(type)),
            ],
          )
        ],
      ),
    ));
  }

  Widget asset(type, beasts) {
    if (type == 6) {
      return Container(
          height: 130,
          child: Row(
            children: [
              RotatedBox(
                child: Text(beasts[0].name),
                quarterTurns: 3,
              ),
              Container(
                  width: 76,
                  child: Column(
                    children: [
                      Container(height: 10),
                      Text('1'),
                      Container(height: 5),
                      MonsterPicSmall(data: beasts[0]),
                      Text('r: ' + beasts[0].remaining.toString(),
                          style: TextStyle(fontSize: 8)),
                    ],
                  )),
              RotatedBox(
                child: Text(beasts[1].name),
                quarterTurns: 3,
              ),
              Container(
                  width: 76,
                  child: Column(
                    children: [
                      Container(height: 10),
                      Text('2'),
                      Container(height: 5),
                      MonsterPicSmall(data: beasts[1]),
                      Text('r: ' + beasts[1].remaining.toString(),
                          style: TextStyle(fontSize: 8)),
                    ],
                  )),
            ],
          ));
    }
    return Container(
        width: 50,
        height: 130,
        child: Row(
          children: [
            RotatedBox(
              child: Text(beasts[0].name),
              quarterTurns: 3,
            ),
            MonsterPicSmall(data: beasts[0]),
          ],
        ));
  }

  Widget text(type) {
    switch (type) {
      case 0:
        return Text("retrieve beast from an auction in order to use again",
            style: TextStyle(fontSize: 10));
        break;
      case 1:
        return Text(
            "retrieve beast from an extraction auction in order to use again",
            style: TextStyle(fontSize: 10));
        break;
      case 2:
        return Text(
            "buy this beast from auction. \n\nWARNING: this beast may be sold before the transaction is completed. Used Gas will not be refunded",
            style: TextStyle(fontSize: 10));
        break;
      case 3:
        return Text(
            'Acquire an extract of this beast. \n\nWARNING: this extract may be sold before the transaction is completed. Used Gas will not be refunded \n WARNING: extracts expire after 24hrs',
            style: TextStyle(fontSize: 10));
        break;
      case 4:
        return Text(
            'Auction this beast\n\nPrice linearly decrements from start price to end price, over the period specified by the duration',
            style: TextStyle(fontSize: 10));
        break;
      case 5:
        return Text('Auction an extract of this beast',
            style: TextStyle(fontSize: 10));
        break;
      case 6:
        return Text(
            'Fuse two beasts together. \n\nWARNING: the order of the beasts will affect the fusing behaviour\n\nWARNING: ensure that the beasts have extractions remaining, else the transaction will fail.',
            style: TextStyle(fontSize: 10));
        break;
      case 7:
        return Text(
            'Level Up this beast. \n\nWARNING: this requires a certain level of experience',
            style: TextStyle(fontSize: 10));
        break;
    }
    return Text(
        "Do not proceed with this transaction unless you are sure of the result",
        style: TextStyle(fontSize: 10));
  }

  Widget extraParameters(type, data) {
    if (type == 4) {
      data.arguments = [
        false,
        BigInt.from(100),
        BigInt.from(50),
        BigInt.from(DateTime.now().millisecondsSinceEpoch / 1000 + 3600)
      ];
      return Card(
          child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Container(
                      child: TextFormField(
                          initialValue: '100',
                          onFieldSubmitted: (value) {
                            data.arguments[1] = BigInt.parse(value);
                            //print(data.arguments[1]);
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'start price',
                              suffix: Container(
                                height: 20,
                                child: Image.asset("lib/assets/essence.png"),
                              )))),
                  Container(height: 20),
                  Container(
                      child: TextFormField(
                          initialValue: '50',
                          onFieldSubmitted: (value) {
                            data.arguments[2] = BigInt.parse(value);
                            //print(data.arguments[2]);
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'end price',
                              suffix: Container(
                                height: 20,
                                child: Image.asset("lib/assets/essence.png"),
                              )))),
                  Container(height: 20),
                  Container(
                      child: TextFormField(
                          initialValue: '3600',
                          onFieldSubmitted: (value) {
                            data.arguments[3] = BigInt.from(int.parse(value) +
                                DateTime.now().millisecondsSinceEpoch / 1000);
                            //print(data.arguments[3]);
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'duration',
                              helperText: 'in seconds',
                              suffix: Container(
                                height: 20,
                                child: Text('s'),
                              )))),
                  //ElevatedButton(child: Text('apply'), onPressed: () {})
                ],
              )));
    }
    if (type == 5) {
      data.arguments = [
        false,
        BigInt.from(100),
        BigInt.from(DateTime.now().millisecondsSinceEpoch / 1000 + 3600)
      ];
      return Card(
          child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Container(
                      child: TextFormField(
                          initialValue: '100',
                          onFieldSubmitted: (value) {
                            data.arguments[1] = BigInt.parse(value);
                            //print(data.arguments[1]);
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'price',
                              suffix: Container(
                                height: 20,
                                child: Image.asset("lib/assets/essence.png"),
                              )))),
                  Container(height: 20),
                  Container(
                      child: TextFormField(
                          initialValue: '3600',
                          onFieldSubmitted: (value) {
                            data.arguments[2] = BigInt.from(int.parse(value) +
                                DateTime.now().millisecondsSinceEpoch / 1000);
                            //print(data.arguments[2]);
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'duration',
                              helperText: 'in seconds',
                              suffix: Container(
                                height: 20,
                                child: Text('s'),
                              )))),
                ],
              )));
    }
    if (type == 6) {
      data.arguments = [false, false, 'qwerty'];
      return Card(
          child: Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                  child: TextFormField(
                      initialValue: 'qwerty',
                      onFieldSubmitted: (value) {
                        data.arguments[2] = value;
                        //print(data.arguments[2]);
                      },
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'name',
                      )))));
    }
    return Container();
  }

  @override
  build(BuildContext context, ScopedReader watch) {
    final data = watch(myEthDataProvider);

    final beasts = data.selectedMonsters;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xfffef0d1),
      appBar: AppBar(
        title: Text('Transaction'),
      ),
      body: Center(
        child: ListView(
          children: [
            dialogContent(type, beasts),
            extraParameters(type, data),
            Card(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text(
                        'disclaimer: transactions are not deterministic, we recommend 1,000,000 gas to ensure success of the transaction.',
                        style: TextStyle(fontSize: 8)),
                    Container(height: 12),
                    Container(
                      child: TextFormField(
                          initialValue: data.gas.toInt().toString(),
                          onFieldSubmitted: (value) {
                            data.changeGas(double.parse(value));
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Gas',
                            helperText: 'Excess gas is refunded.',
                          )),
                    ),
                    Container(height: 30),
                    Container(
                      child: TextFormField(
                          onFieldSubmitted: (value) {
                            data.changePrice(double.parse(value));
                          },
                          initialValue:
                              (data.gasPriceInWei / 1000000000).toString(),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Price',
                            suffix: Text('GWEI'),
                          )),
                    )
                  ],
                ),
              ),
            ),
            Container(height: 10),
            Card(
                child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Stack(children: [
                    TextFormField(
                        enabled: false,
                        initialValue: ' ',
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Total Cost',
                          suffix: Text('Eth'),
                        )),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 20, 0, 0),
                      child:
                          Text((data.total / 1000000000000000000).toString()),
                    ),
                  ]),
                ],
              ),
            )),
            Container(height: 10),
            Card(
                child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Stack(children: [
                    TextFormField(
                        enabled: false,
                        initialValue: ' ',
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'your remaining balance',
                          suffix: Text('Eth'),
                        )),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 20, 0, 0),
                      child: Text(((data.etherBalance - data.total) /
                              1000000000000000000)
                          .toString()),
                    ),
                  ]),
                ],
              ),
            )),
            Spacer(),
            Row(
              children: [
                Spacer(),
                ElevatedButton(
                    child: Text("cancel"),
                    onPressed: () {
                      Navigator.pop(context, 0);
                      data.selectedAuctions = [];
                      data.selectedMonsters = [];
                    }),
                Container(width: 5),
                ElevatedButton(
                    child: Text("Submit"),
                    onPressed: () async {
                      if (await showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text('This action is irreversible!'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Approve'),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                            ),
                            TextButton(
                                child: Text('cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                })
                          ],
                        ),
                      )) {
                        await data.createTransaction(type);
                        Navigator.pop(context, 1);
                      }
                    }),
              ],
            ),
          ],
        ),
      ),
    );
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
