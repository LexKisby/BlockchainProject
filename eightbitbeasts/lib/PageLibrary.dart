library page_classes;

import 'package:eightbitbeasts/main.dart';
import 'package:http/http.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

//import 'package:intl/intl.dart';
import 'dart:async';
import 'package:pixel_border/pixel_border.dart';
import 'package:flutter/services.dart';

part "components/MonsterCard.dart";
part "components/Currency.dart";

part "ethlogic/ethlogic.dart";

part "lib2/Inventorylib.dart";
part "lib2/Auctionlib.dart";
part "lib2/Capturelib.dart";
part "lib2/Hatchlib.dart";
part "lib2/settingslib.dart";
part "lib2/Detailslib.dart";

part "utils/classes.dart";
part "utils/style.dart";
part "notifiers.dart";

const myAddress = "0x6c7382C47830C20B1A2746dDd5Bb48f2EaB08795";
const privateKey =
    '09fa63a415d391bcc3bfbd9025eb88e0da80d9924e1e7ed00b665261d14061a5';

const List<String> contract_addresses = [
  "0x0B73580Ae781D7cde7dF3094d9e085bB0C248C48"
];

//fusion, market, battle
const contractAddresses = {
  'mother': [
    '0x22c94BA007a721Ea20af612A1F03fB8F97a0dDd1',
    '''[
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			}
		],
		"name": "addTrusted",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_beastId",
				"type": "uint256"
			},
			{
				"internalType": "uint32",
				"name": "_xp",
				"type": "uint32"
			}
		],
		"name": "addXp",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_beastId",
				"type": "uint256"
			}
		],
		"name": "battleLoss",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_beastId",
				"type": "uint256"
			}
		],
		"name": "battleWin",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "beastId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "to",
				"type": "address"
			}
		],
		"name": "BeastTransfer",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "changeOwner",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "string",
				"name": "aspect",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "newValue",
				"type": "uint256"
			}
		],
		"name": "ContractUpdate",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_name",
				"type": "string"
			},
			{
				"components": [
					{
						"internalType": "uint16",
						"name": "hp",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "attackSpeed",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "evasion",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "primaryDamage",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "secondaryDamage",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "resistance",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "accuracy",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "constitution",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "intelligence",
						"type": "uint16"
					}
				],
				"internalType": "struct MotherCore.Stats",
				"name": "_stats",
				"type": "tuple"
			},
			{
				"internalType": "uint32",
				"name": "_level",
				"type": "uint32"
			},
			{
				"internalType": "uint32",
				"name": "_xp",
				"type": "uint32"
			},
			{
				"internalType": "uint32",
				"name": "_readyTime",
				"type": "uint32"
			},
			{
				"internalType": "uint16",
				"name": "_winCount",
				"type": "uint16"
			},
			{
				"internalType": "uint16",
				"name": "_lossCount",
				"type": "uint16"
			},
			{
				"internalType": "uint8",
				"name": "_grade",
				"type": "uint8"
			},
			{
				"internalType": "uint8",
				"name": "_extractionsRemaining",
				"type": "uint8"
			},
			{
				"internalType": "uint8[22]",
				"name": "_dna",
				"type": "uint8[22]"
			},
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			}
		],
		"name": "createBeast",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "int256",
				"name": "_quantity",
				"type": "int256"
			},
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			},
			{
				"internalType": "uint8",
				"name": "_type",
				"type": "uint8"
			}
		],
		"name": "depositCurrency",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_beastId",
				"type": "uint256"
			}
		],
		"name": "levelUp",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "beastId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "uint32",
				"name": "lvl",
				"type": "uint32"
			}
		],
		"name": "LvlUp",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "beastId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "newName",
				"type": "string"
			}
		],
		"name": "NameChange",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "beastId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "uint8[22]",
				"name": "dna",
				"type": "uint8[22]"
			}
		],
		"name": "NewBeast",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "tamerId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "tamerAddress",
				"type": "address"
			}
		],
		"name": "NewTamer",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "oldOwner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "OwnerSet",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_beastId",
				"type": "uint256"
			}
		],
		"name": "reduceExtractions",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			}
		],
		"name": "removeTrusted",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_beastId",
				"type": "uint256"
			},
			{
				"internalType": "uint32",
				"name": "_time",
				"type": "uint32"
			}
		],
		"name": "setReadyTime",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint16",
				"name": "_beastId",
				"type": "uint16"
			},
			{
				"internalType": "uint16",
				"name": "_hp",
				"type": "uint16"
			},
			{
				"internalType": "uint16",
				"name": "_attackSpeed",
				"type": "uint16"
			},
			{
				"internalType": "uint16",
				"name": "_evasion",
				"type": "uint16"
			},
			{
				"internalType": "uint16",
				"name": "_primaryDamage",
				"type": "uint16"
			},
			{
				"internalType": "uint16",
				"name": "_secondaryDamage",
				"type": "uint16"
			},
			{
				"internalType": "uint16",
				"name": "_resistance",
				"type": "uint16"
			},
			{
				"internalType": "uint16",
				"name": "_accuracy",
				"type": "uint16"
			},
			{
				"internalType": "uint16",
				"name": "_constitution",
				"type": "uint16"
			},
			{
				"internalType": "uint16",
				"name": "_intelligence",
				"type": "uint16"
			}
		],
		"name": "setStats",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "beastId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"components": [
					{
						"internalType": "uint16",
						"name": "hp",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "attackSpeed",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "evasion",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "primaryDamage",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "secondaryDamage",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "resistance",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "accuracy",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "constitution",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "intelligence",
						"type": "uint16"
					}
				],
				"indexed": false,
				"internalType": "struct MotherCore.Stats",
				"name": "stats",
				"type": "tuple"
			}
		],
		"name": "StatBoost",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_beastId",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "_from",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "_to",
				"type": "address"
			}
		],
		"name": "transferBeast",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "int256",
				"name": "_quantity",
				"type": "int256"
			},
			{
				"internalType": "address",
				"name": "_from",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "_to",
				"type": "address"
			},
			{
				"internalType": "uint8",
				"name": "_type",
				"type": "uint8"
			}
		],
		"name": "transferCurrency",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_beastId",
				"type": "uint256"
			},
			{
				"internalType": "uint32",
				"name": "_factor",
				"type": "uint32"
			}
		],
		"name": "triggerRecoveryPeriod",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "withdraw",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "_getOwner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "beasts",
		"outputs": [
			{
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"components": [
					{
						"internalType": "uint16",
						"name": "hp",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "attackSpeed",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "evasion",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "primaryDamage",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "secondaryDamage",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "resistance",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "accuracy",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "constitution",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "intelligence",
						"type": "uint16"
					}
				],
				"internalType": "struct MotherCore.Stats",
				"name": "stats",
				"type": "tuple"
			},
			{
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			},
			{
				"internalType": "uint32",
				"name": "level",
				"type": "uint32"
			},
			{
				"internalType": "uint32",
				"name": "xp",
				"type": "uint32"
			},
			{
				"internalType": "uint32",
				"name": "readyTime",
				"type": "uint32"
			},
			{
				"internalType": "uint16",
				"name": "winCount",
				"type": "uint16"
			},
			{
				"internalType": "uint16",
				"name": "lossCount",
				"type": "uint16"
			},
			{
				"internalType": "uint8",
				"name": "grade",
				"type": "uint8"
			},
			{
				"internalType": "uint8",
				"name": "extractionsRemaining",
				"type": "uint8"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "beastToTamer",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "checkBalance",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "currency",
		"outputs": [
			{
				"internalType": "int256",
				"name": "",
				"type": "int256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint8[22]",
				"name": "_dna",
				"type": "uint8[22]"
			}
		],
		"name": "dnaExists",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_beastId",
				"type": "uint256"
			}
		],
		"name": "getBeast",
		"outputs": [
			{
				"components": [
					{
						"internalType": "string",
						"name": "name",
						"type": "string"
					},
					{
						"components": [
							{
								"internalType": "uint16",
								"name": "hp",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "attackSpeed",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "evasion",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "primaryDamage",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "secondaryDamage",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "resistance",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "accuracy",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "constitution",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "intelligence",
								"type": "uint16"
							}
						],
						"internalType": "struct MotherCore.Stats",
						"name": "stats",
						"type": "tuple"
					},
					{
						"internalType": "uint256",
						"name": "id",
						"type": "uint256"
					},
					{
						"internalType": "uint32",
						"name": "level",
						"type": "uint32"
					},
					{
						"internalType": "uint32",
						"name": "xp",
						"type": "uint32"
					},
					{
						"internalType": "uint32",
						"name": "readyTime",
						"type": "uint32"
					},
					{
						"internalType": "uint16",
						"name": "winCount",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "lossCount",
						"type": "uint16"
					},
					{
						"internalType": "uint8",
						"name": "grade",
						"type": "uint8"
					},
					{
						"internalType": "uint8",
						"name": "extractionsRemaining",
						"type": "uint8"
					},
					{
						"internalType": "uint8[22]",
						"name": "dna",
						"type": "uint8[22]"
					}
				],
				"internalType": "struct MotherCore.Beast",
				"name": "",
				"type": "tuple"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getBeasts",
		"outputs": [
			{
				"components": [
					{
						"internalType": "string",
						"name": "name",
						"type": "string"
					},
					{
						"components": [
							{
								"internalType": "uint16",
								"name": "hp",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "attackSpeed",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "evasion",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "primaryDamage",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "secondaryDamage",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "resistance",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "accuracy",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "constitution",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "intelligence",
								"type": "uint16"
							}
						],
						"internalType": "struct MotherCore.Stats",
						"name": "stats",
						"type": "tuple"
					},
					{
						"internalType": "uint256",
						"name": "id",
						"type": "uint256"
					},
					{
						"internalType": "uint32",
						"name": "level",
						"type": "uint32"
					},
					{
						"internalType": "uint32",
						"name": "xp",
						"type": "uint32"
					},
					{
						"internalType": "uint32",
						"name": "readyTime",
						"type": "uint32"
					},
					{
						"internalType": "uint16",
						"name": "winCount",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "lossCount",
						"type": "uint16"
					},
					{
						"internalType": "uint8",
						"name": "grade",
						"type": "uint8"
					},
					{
						"internalType": "uint8",
						"name": "extractionsRemaining",
						"type": "uint8"
					},
					{
						"internalType": "uint8[22]",
						"name": "dna",
						"type": "uint8[22]"
					}
				],
				"internalType": "struct MotherCore.Beast[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_tamer",
				"type": "address"
			}
		],
		"name": "getBeastsByTamer",
		"outputs": [
			{
				"components": [
					{
						"internalType": "string",
						"name": "name",
						"type": "string"
					},
					{
						"components": [
							{
								"internalType": "uint16",
								"name": "hp",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "attackSpeed",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "evasion",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "primaryDamage",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "secondaryDamage",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "resistance",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "accuracy",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "constitution",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "intelligence",
								"type": "uint16"
							}
						],
						"internalType": "struct MotherCore.Stats",
						"name": "stats",
						"type": "tuple"
					},
					{
						"internalType": "uint256",
						"name": "id",
						"type": "uint256"
					},
					{
						"internalType": "uint32",
						"name": "level",
						"type": "uint32"
					},
					{
						"internalType": "uint32",
						"name": "xp",
						"type": "uint32"
					},
					{
						"internalType": "uint32",
						"name": "readyTime",
						"type": "uint32"
					},
					{
						"internalType": "uint16",
						"name": "winCount",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "lossCount",
						"type": "uint16"
					},
					{
						"internalType": "uint8",
						"name": "grade",
						"type": "uint8"
					},
					{
						"internalType": "uint8",
						"name": "extractionsRemaining",
						"type": "uint8"
					},
					{
						"internalType": "uint8[22]",
						"name": "dna",
						"type": "uint8[22]"
					}
				],
				"internalType": "struct MotherCore.Beast[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "howManyBeasts",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "tamerBeastCount",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]'''
  ],
  'market': [
    '0x8aB2d44e544e44bc0B2B1E7Bd56F3A4f152F3F80',
    '''[
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "beastId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "seller",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "price",
				"type": "uint256"
			}
		],
		"name": "BeastAddedForExtract",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "beastId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "seller",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "startPrice",
				"type": "uint256"
			}
		],
		"name": "BeastAddedToAuction",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "beastId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "newTamer",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "price",
				"type": "uint256"
			}
		],
		"name": "BeastAuctioned",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "beastId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "tamer",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "price",
				"type": "uint256"
			}
		],
		"name": "BeastExtractAuctioned",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "oldOwner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "OwnerSet",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "beastId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "tamer",
				"type": "address"
			}
		],
		"name": "RetrievedBeast",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "address",
				"name": "tamer",
				"type": "address"
			}
		],
		"name": "RubiesExchangedForEssence",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			}
		],
		"name": "addTrusted",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_beastId",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_startPrice",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_endPrice",
				"type": "uint256"
			},
			{
				"internalType": "uint32",
				"name": "_endTime",
				"type": "uint32"
			}
		],
		"name": "auctionBeast",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_beastId",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_price",
				"type": "uint256"
			},
			{
				"internalType": "uint32",
				"name": "_endTime",
				"type": "uint32"
			}
		],
		"name": "auctionBeastExtract",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_beastId",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_auctionNo",
				"type": "uint256"
			}
		],
		"name": "buyBeastFromAuction",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_beastId",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_auctionNo",
				"type": "uint256"
			}
		],
		"name": "buyExtractFromAuction",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "changeOwner",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "exchangeRubiesForEssence",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_beastId",
				"type": "uint256"
			}
		],
		"name": "removeExtract",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			}
		],
		"name": "removeTrusted",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_beastId",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_auctionNo",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_type",
				"type": "uint256"
			}
		],
		"name": "retrieve",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			}
		],
		"name": "updateMotherAddress",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "_getOwner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "auctions",
		"outputs": [
			{
				"components": [
					{
						"internalType": "string",
						"name": "name",
						"type": "string"
					},
					{
						"components": [
							{
								"internalType": "uint16",
								"name": "hp",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "attackSpeed",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "evasion",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "primaryDamage",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "secondaryDamage",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "resistance",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "accuracy",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "constitution",
								"type": "uint16"
							},
							{
								"internalType": "uint16",
								"name": "intelligence",
								"type": "uint16"
							}
						],
						"internalType": "struct MotherCore.Stats",
						"name": "stats",
						"type": "tuple"
					},
					{
						"internalType": "uint256",
						"name": "id",
						"type": "uint256"
					},
					{
						"internalType": "uint32",
						"name": "level",
						"type": "uint32"
					},
					{
						"internalType": "uint32",
						"name": "xp",
						"type": "uint32"
					},
					{
						"internalType": "uint32",
						"name": "readyTime",
						"type": "uint32"
					},
					{
						"internalType": "uint16",
						"name": "winCount",
						"type": "uint16"
					},
					{
						"internalType": "uint16",
						"name": "lossCount",
						"type": "uint16"
					},
					{
						"internalType": "uint8",
						"name": "grade",
						"type": "uint8"
					},
					{
						"internalType": "uint8",
						"name": "extractionsRemaining",
						"type": "uint8"
					},
					{
						"internalType": "uint8[22]",
						"name": "dna",
						"type": "uint8[22]"
					}
				],
				"internalType": "struct MotherCore.Beast",
				"name": "beast",
				"type": "tuple"
			},
			{
				"internalType": "address",
				"name": "seller",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "startPrice",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "endPrice",
				"type": "uint256"
			},
			{
				"internalType": "uint32",
				"name": "startTime",
				"type": "uint32"
			},
			{
				"internalType": "uint32",
				"name": "endTime",
				"type": "uint32"
			},
			{
				"internalType": "bool",
				"name": "retrieved",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "extractAuctions",
		"outputs": [
			{
				"components": [
					{
						"internalType": "address",
						"name": "owner",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "beastId",
						"type": "uint256"
					},
					{
						"internalType": "uint32",
						"name": "expiry",
						"type": "uint32"
					}
				],
				"internalType": "struct Market.Extract",
				"name": "extract",
				"type": "tuple"
			},
			{
				"internalType": "address",
				"name": "seller",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "price",
				"type": "uint256"
			},
			{
				"internalType": "uint32",
				"name": "endTime",
				"type": "uint32"
			},
			{
				"internalType": "bool",
				"name": "retrieved",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "extractToTamer",
		"outputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "beastId",
				"type": "uint256"
			},
			{
				"internalType": "uint32",
				"name": "expiry",
				"type": "uint32"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getAuctions",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_tamer",
				"type": "address"
			}
		],
		"name": "getExtracts",
		"outputs": [
			{
				"internalType": "uint256[]",
				"name": "",
				"type": "uint256[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]'''
  ],
  'generator': [
    '0x9cd7E61B6668ef2D2820d35276eC0b6E6ceA3f10',
    '''[
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			}
		],
		"name": "addTrusted",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "changeOwner",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_name",
				"type": "string"
			},
			{
				"internalType": "uint8",
				"name": "_grade",
				"type": "uint8"
			},
			{
				"internalType": "address",
				"name": "_tamer",
				"type": "address"
			}
		],
		"name": "generateRandomBeastFromGrade",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_name",
				"type": "string"
			}
		],
		"name": "generateStarterBeast",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "oldOwner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "OwnerSet",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			}
		],
		"name": "removeTrusted",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			}
		],
		"name": "updateMotherAddress",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "_getOwner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]'''
  ],
  'fusion': [
    '0x4Fa904D83315C8D111D7253eb56c425e78846831',
    '''[
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			}
		],
		"name": "addTrusted",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_primaryId",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_secondaryId",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "_name",
				"type": "string"
			}
		],
		"name": "BeastFusionSwitch",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "changeOwner",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "oldOwner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "OwnerSet",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			}
		],
		"name": "removeTrusted",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			}
		],
		"name": "updateMarketAddress",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			}
		],
		"name": "updateMotherAddress",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "_getOwner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]'''
  ],
  'dungeon': [
    '0x55CEad2FCBD0E17B65D2D53714E13560C6fBF737',
    '''[
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "beast1",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "beast2",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "tamer",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "difficulty",
				"type": "uint256"
			}
		],
		"name": "DungeonChallenged",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "beast1",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "beast2",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "tamer",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "difficulty",
				"type": "uint256"
			}
		],
		"name": "DungeonFailed",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "oldOwner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "OwnerSet",
		"type": "event"
	},
	{
		"inputs": [],
		"name": "_getOwner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			}
		],
		"name": "addTrusted",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "changeOwner",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_beastId1",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_beastId2",
				"type": "uint256"
			},
			{
				"internalType": "uint32",
				"name": "_dungeonLvl",
				"type": "uint32"
			}
		],
		"name": "enterDungeon",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			}
		],
		"name": "removeTrusted",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			}
		],
		"name": "updateMotherAddress",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	}
]'''
  ],
  'battle': [
    '0x0f8bEEbA79355e5b358dAC45BC135049a919FA03',
    '''[
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "beastId",
				"type": "uint256"
			}
		],
		"name": "ChallengeMade",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "address",
				"name": "challenger",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "challengerBeastId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "challenged",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "challengedBeastId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "victor",
				"type": "address"
			}
		],
		"name": "Duel",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "oldOwner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "OwnerSet",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_index",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_beastId",
				"type": "uint256"
			}
		],
		"name": "acceptChallenge",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			}
		],
		"name": "addTrusted",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "changeOwner",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "_beastId",
				"type": "uint256"
			}
		],
		"name": "makeChallenge",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			}
		],
		"name": "removeTrusted",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			}
		],
		"name": "updateMotherAddress",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "_getOwner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "tamerRecievedChallenges",
		"outputs": [
			{
				"internalType": "address",
				"name": "challenger",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "beast",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "index",
				"type": "uint256"
			},
			{
				"internalType": "bool",
				"name": "expired",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "tamerSentChallenge",
		"outputs": [
			{
				"internalType": "address",
				"name": "challenged",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "beastId",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "index",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]'''
  ]
};
