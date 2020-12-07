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
  double rubies;
  double essence;
  List<Monster> marketMonstersForBreeding;
  List<Auction> marketMonstersForBuying;
  bool hasMonsterList = false;
  bool hasCurrency = false;
}

class EthChangeNotifier extends ChangeNotifier {
  EthData data;
  Client httpClient;
  Web3Client ethClient;

  void init() async {
    data = new EthData();
    httpClient = new Client();
    ethClient = new Web3Client(
        "https://rinkeby.infura.io/v3/c0ba200103214c0b9b002e5591ab09f7",
        httpClient);
    data.hasMonsterList = false;
    data.hasCurrency = false;
    data.rubies = 0;
    data.essence = 0;
    print('getting currency');
    await getCurrency('0x0b1B455acfbB4476c879c96EcDF315913FD22518');
    print('got currency');
    data.hasCurrency = true;
    return;
  }

  void update() async {
    print('updating');
    //data.rubies += 1;
    //data.essence += 10000;
    //10.0.await setRubyBalance('0x0b1B455acfbB4476c879c96EcDF315913FD22518', 5);
    print('set balance of rubies');
    await getCurrency('0x0b1B455acfbB4476c879c96EcDF315913FD22518');
    print('done');
    //get other stuffs again.
  }

//#########################################################################################
  Future<DeployedContract> loadContract() async {
    String prepABI = """[
    {
      "name": "CheckedSt",
      "inputs": [
        {
          "type": "address",
          "name": "name",
          "indexed": false
        },
        {
          "type": "uint256",
          "name": "new_num",
          "indexed": false
        }
      ],
      "anonymous": false,
      "type": "event"
    },
    {
      "name": "CheckedRuby",
      "inputs": [
        {
          "type": "address",
          "name": "name",
          "indexed": false
        },
        {
          "type": "uint256",
          "name": "new_num",
          "indexed": false
        }
      ],
      "anonymous": false,
      "type": "event"
    },
    {
      "name": "CheckedEss",
      "inputs": [
        {
          "type": "address",
          "name": "name",
          "indexed": false
        },
        {
          "type": "uint256",
          "name": "new_num",
          "indexed": false
        }
      ],
      "anonymous": false,
      "type": "event"
    },
    {
      "name": "set",
      "outputs": [],
      "inputs": [
        {
          "type": "uint256",
          "name": "new_value"
        }
      ],
      "stateMutability": "nonpayable",
      "type": "function",
      "gas": 37162
    },
    {
      "name": "get",
      "outputs": [
        {
          "type": "uint256",
          "name": ""
        }
      ],
      "inputs": [],
      "stateMutability": "view",
      "type": "function",
      "gas": 1091
    },
    {
      "name": "getRubyBalance",
      "outputs": [
        {
          "type": "uint256",
          "name": ""
        }
      ],
      "inputs": [],
      "stateMutability": "view",
      "type": "function",
      "gas": 1121
    },
    {
      "name": "setRubyBalance",
      "outputs": [],
      "inputs": [
        {
          "type": "uint256",
          "name": "new_value"
        }
      ],
      "stateMutability": "nonpayable",
      "type": "function",
      "gas": 37252
    },
    {
      "name": "getEssenceBalance",
      "outputs": [
        {
          "type": "uint256",
          "name": ""
        }
      ],
      "inputs": [],
      "stateMutability": "view",
      "type": "function",
      "gas": 1181
    },
    {
      "name": "setEssenceBalance",
      "outputs": [],
      "inputs": [
        {
          "type": "uint256",
          "name": "new_value"
        }
      ],
      "stateMutability": "nonpayable",
      "type": "function",
      "gas": 37312
    }
  ]""";
    //String abi = await rootBundle.loadString(prepABI);
    String contractAddress = "0x0b1B455acfbB4476c879c96EcDF315913FD22518";

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
    List<dynamic> response = await query("getRubyBalance", []);
    data.rubies = response[0];
  }

  //ingame currency, is an erc 20 token, rare, called "Essence"
  Future<void> getEssenceBalance(String targetAddress) async {
    EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    List<dynamic> response = await query("getEssenceBalance", []);
    data.essence = response[0];
  }

  Future<void> getCurrency(String targetAddress) async {
    await getEssenceBalance(targetAddress);
    await getRubyBalance(targetAddress);
    data.hasCurrency = true;
  }

  Future<void> setRubyBalance(String targetAddress, int amount) async {
    String response = await submit("setRubyBalance", [5]);
    print(response);
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
