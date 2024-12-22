// import 'package:flutter_web3/flutter_web3.dart';
// import 'package:http/http.dart';
// import 'dart:convert';
// import 'package:flutter/services.dart';

// class BlockchainService {
//   static const String contractAddress = "0x4b152Cd78faA86470838e760DB15Fc68c96Eb83C";
  
//   late Contract _contract;
//   late Provider _provider;
//   late Signer _signer;

//   Future<void> initialize() async {
//     if (Ethereum.isSupported) {
//       try {
//         // Request account access
//         final accounts = await ethereum!.requestAccount();
        
//         // Get provider and signer
//         _provider = provider!;
//         _signer = provider!.getSigner();
        
//         // Load ABI
//         final abiString = await rootBundle.loadString('assets/abi.json');
//         final abi = jsonDecode(abiString);
        
//         // Create contract instance
//         _contract = Contract(
//           contractAddress,
//           Interface(abi),
//           _signer,
//         );
//       } catch (e) {
//         throw Exception('Failed to initialize blockchain: $e');
//       }
//     } else {
//       throw Exception('Web3 is not supported in this browser');
//     }
//   }

//   Future<Map<String, dynamic>> getProductJourney(String productId) async {
//     try {
//       final result = await _contract.call<List<dynamic>>('getProductJourney', [BigInt.parse(productId)]);
      
//       // Parse the blockchain data
//       final steps = result[0].map((step) => {
//         'vendor': step[0],
//         'consumer': step[1],
//         'organization': step[2],
//         'location': step[3],
//         'status': step[4],
//         'timestamp': DateTime.fromMillisecondsSinceEpoch(
//           (step[5] as BigInt).toInt() * 1000,
//         ),
//         'quantity': step[6].toString(),
//       }).toList();

//       return {
//         'productId': productId,
//         'steps': steps,
//       };
//     } catch (e) {
//       throw Exception('Failed to get product journey: $e');
//     }
//   }
// }