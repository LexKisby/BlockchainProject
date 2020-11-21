part of page_classes;

Future<DeployedContract> loadContract() async {
  String abi = await rootBundle.loadString("assets/abi/abi.json");
  String contractAddress = "";

  final contract = DeployedContract(ContractAbi.fromJson(abi, "mycoin"),
      EthereumAddress.fromHex(contractAddress));

  return contract;
}
