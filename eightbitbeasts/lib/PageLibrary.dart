library page_classes;

import 'package:eightbitbeasts/main.dart';
import 'package:http/http.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/all.dart';
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
const myPrivateKey =
    '09fa63a415d391bcc3bfbd9025eb88e0da80d9924e1e7ed00b665261d14061a5';
const contract_address = "0x06108514fD453A242Bd8B4f35A9487F6200508Fa";
const abi_raw = """[
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_value",
				"type": "uint256"
			}
		],
		"name": "setEssenceBalance",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_value",
				"type": "uint256"
			}
		],
		"name": "setRubyBalance",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "num",
				"type": "uint256"
			}
		],
		"name": "store",
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
		"name": "getEssenceBalance",
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
				"name": "_address",
				"type": "address"
			}
		],
		"name": "getRubyBalance",
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
		"inputs": [],
		"name": "retrieve",
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
]""";
