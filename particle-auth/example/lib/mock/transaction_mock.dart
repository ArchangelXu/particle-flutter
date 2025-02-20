import 'dart:convert';
import 'dart:math';

import 'package:particle_auth_example/mock/test_account.dart';
import 'package:particle_auth_example/model/serialize_sol_transreqentity.dart';
import 'package:particle_auth_example/model/serialize_trans_result_entity.dart';
import 'package:particle_auth_example/net/particle_rpc.dart';

class TransactionMock {
  static Future<String> mockSolanaTransaction(String sendPubKey) async {
    final req = SerializeSOLTransReqEntity();
    req.lamports = TestAccount.solana.amount;
    req.receiver = TestAccount.solana.publicAddress;
    req.sender = sendPubKey;

    SerializeTransResultEntity resultEntity =
        await SolanaService.enhancedSerializeTransaction(req);
    return resultEntity.result.transaction.serialized;
  }

  /// Mock a transaction 
  /// Send contract token in our test account, chain id 5.
  /// Chain id 5 is Ethereum goerli, supports eip 1155, so the transaction is type2.
  /// If your chain id did not support eip 1155, go to method mockEvmTransactionNoSupportEip1155.
  static Future<String> mockEvmSendToken(String sendPubKey) async {
    String sender = sendPubKey;
    String receiver = TestAccount.evm.receiverAddress;
    String contractAddress = TestAccount.evm.tokenContractAddress;
    BigInt amount = TestAccount.evm.amount;
    String to = contractAddress;
    final erc20Resp =
        await EvmService.erc20Transfer(contractAddress, receiver, amount);
    final data = jsonDecode(erc20Resp)["result"];

    final gasLimitResult = await EvmService.ethEstimateGas(
        sender, to, "0x0", data);
    final jsonObj = jsonDecode(gasLimitResult);
    final gasLimit = jsonObj["result"];

    final gasFeesResult = await EvmService.suggestedGasFees();
    final maxFeePerGas = double.parse(
        jsonDecode(gasFeesResult)["result"]["high"]["maxFeePerGas"]);
    final maxFeePerGasHex =
        "0x${BigInt.from(maxFeePerGas * pow(10, 9)).toRadixString(16)}";

    final maxPriorityFeePerGas = double.parse(
        jsonDecode(gasFeesResult)["result"]["high"]["maxPriorityFeePerGas"]);
    final maxPriorityFeePerGasHex =
        "0x${BigInt.from(maxPriorityFeePerGas * pow(10, 9)).toRadixString(16)}";

    // evm transaction
    final req = {
      "from": sender,
      "to": to,
      "gasLimit": gasLimit,
      "value": "0x0",
      "maxFeePerGas": maxFeePerGasHex,
      "maxPriorityFeePerGas": maxPriorityFeePerGasHex,
      "data": data,
      "type": "0x2",
      "nonce": "0x0",
      "chainId": "0x${TestAccount.evm.chainId.toRadixString(16)}",
    };
    //to hexString
    final reqStr = jsonEncode(req);
    final reqHex = utf8.encode(reqStr).map((e) => e.toRadixString(16)).join();

    return "0x$reqHex";
  }

  /// Mock a transaction
  /// Send native token in our test account, chain id 5.
  /// Chain id 5 is Ethereum goerli, supports eip 1155.
  static Future<String> mockEvmSendNative(String sendPubKey) async {
    String sender = sendPubKey;
    String receiver = TestAccount.evm.receiverAddress;
    BigInt amount = TestAccount.evm.amount;
    String to = receiver;
    const data = "0x";
    final gasLimitResult = await EvmService.ethEstimateGas(
        sender, to, "0x0", data);
    final jsonObj = jsonDecode(gasLimitResult);
    final gasLimit = jsonObj["result"];

    final gasFeesResult = await EvmService.suggestedGasFees();
    final maxFeePerGas = double.parse(
        jsonDecode(gasFeesResult)["result"]["high"]["maxFeePerGas"]);
    final maxFeePerGasHex =
        "0x${BigInt.from(maxFeePerGas * pow(10, 9)).toRadixString(16)}";

    // evm transaction
    final req = {
      "from": sender,
      "to": to,
      "gasLimit": gasLimit,
      "value": "0x${amount.toRadixString(16)}",
      "gasPrice": maxFeePerGasHex,
      "data": data,
      "type": "0x0",
      "nonce": "0x0",
      "chainId": "0x${TestAccount.evm.chainId.toRadixString(16)}",
    };
    //to hexString
    final reqStr = jsonEncode(req);
    final reqHex = utf8.encode(reqStr).map((e) => e.toRadixString(16)).join();

    return "0x$reqHex";
  }

  /// Mock a transaction that chain not support eip1155. 
  /// The example show you how to config a type0/legacy transaction.
  /// You can replease parameters to test.
  static Future<String> mockEvmSendTokenUnsupportEip1559(String sendPubKey) async {
    String sender = sendPubKey;
    String receiver = TestAccount.evm.receiverAddress;
    String contractAddress = TestAccount.evm.tokenContractAddress;
    BigInt amount = TestAccount.evm.amount;
    String to = contractAddress;
    final erc20Resp =
        await EvmService.erc20Transfer(contractAddress, receiver, amount);
    final data = jsonDecode(erc20Resp)["result"];

    final gasLimitResult = await EvmService.ethEstimateGas(
        sender, to, "0x0", data);
    final jsonObj = jsonDecode(gasLimitResult);
    final gasLimit = jsonObj["result"];

    final gasFeesResult = await EvmService.suggestedGasFees();
    final maxFeePerGas = double.parse(
        jsonDecode(gasFeesResult)["result"]["high"]["maxFeePerGas"]);
    final maxFeePerGasHex =
        "0x${BigInt.from(maxFeePerGas * pow(10, 9)).toRadixString(16)}";

    // evm transaction
    final req = {
      "from": sender,
      "to": to,
      "gasLimit": gasLimit,
      "value": "0x0",
      "gasPrice": maxFeePerGasHex,
      "data": data,
      "type": "0x0",
      "nonce": "0x0",
      "chainId": "0x${TestAccount.evm.chainId.toRadixString(16)}",
    };
    //to hexString
    final reqStr = jsonEncode(req);
    final reqHex = utf8.encode(reqStr).map((e) => e.toRadixString(16)).join();

    return "0x$reqHex";
  }

  /// Mock a transaction 
  /// Send erc721 nft in our test account, chain id 5.
  /// Chain id 5 is Ethereum goerli, supports eip 1559, so the transaction is type2.
  /// If your chain id did not support eip 1559, go to method mockEvmSendTokenUnsupportEip1559.
  static Future<String> mockEvmErc721NFT(String sendPubKey) async {
    String sender = sendPubKey;
    String receiver = TestAccount.evm.receiverAddress;
    String contractAddress = TestAccount.evm.nftContractAddress;
    String tokenId = TestAccount.evm.nftTokenId;
    String to = contractAddress;

    final erc20Resp =
        await EvmService.erc721SafeTransferFrom(contractAddress, sender, receiver, tokenId);
    final data = jsonDecode(erc20Resp)["result"];

    final gasLimitResult = await EvmService.ethEstimateGas(
        sender, to, "0x0", data);
    final jsonObj = jsonDecode(gasLimitResult);
    final gasLimit = jsonObj["result"];

    final gasFeesResult = await EvmService.suggestedGasFees();
    final maxFeePerGas = double.parse(
        jsonDecode(gasFeesResult)["result"]["high"]["maxFeePerGas"]);
    final maxFeePerGasHex =
        "0x${BigInt.from(maxFeePerGas * pow(10, 9)).toRadixString(16)}";

    final maxPriorityFeePerGas = double.parse(
        jsonDecode(gasFeesResult)["result"]["high"]["maxPriorityFeePerGas"]);
    final maxPriorityFeePerGasHex =
        "0x${BigInt.from(maxPriorityFeePerGas * pow(10, 9)).toRadixString(16)}";

    // evm transaction
    final req = {
      "from": sender,
      "to": to,
      "gasLimit": gasLimit,
      "value": "0x0",
      "maxFeePerGas": maxFeePerGasHex,
      "maxPriorityFeePerGas": maxPriorityFeePerGasHex,
      "data": data,
      "type": "0x2",
      "nonce": "0x0",
      "chainId": "0x${TestAccount.evm.chainId.toRadixString(16)}",
    };
    //to hexString
    final reqStr = jsonEncode(req);
    final reqHex = utf8.encode(reqStr).map((e) => e.toRadixString(16)).join();

    return "0x$reqHex";
  }

  /// Mock a transaction 
  /// Send erc1155 nft in our test account, chain id 5.
  /// Chain id 5 is Ethereum goerli, supports eip 1559, so the transaction is type2.
  /// If your chain id did not support eip 1559, go to method mockEvmSendTokenUnsupportEip1559.
  static Future<String> mockEvmErc1155NFT(String sendPubKey) async {
    String sender = sendPubKey;
    String receiver = TestAccount.evm.receiverAddress;
    String contractAddress = TestAccount.evm.nftContractAddress;
    String tokenId = TestAccount.evm.nftTokenId;
    String to = contractAddress;
    String amount = "1";
    final erc20Resp =
        await EvmService.erc1155SafeTransferFrom(contractAddress, sender, receiver, tokenId, amount, "0x");
    final data = jsonDecode(erc20Resp)["result"];

    final gasLimitResult = await EvmService.ethEstimateGas(
        sender, to, "0x0", data);
    final jsonObj = jsonDecode(gasLimitResult);
    final gasLimit = jsonObj["result"];

    final gasFeesResult = await EvmService.suggestedGasFees();
    final maxFeePerGas = double.parse(
        jsonDecode(gasFeesResult)["result"]["high"]["maxFeePerGas"]);
    final maxFeePerGasHex =
        "0x${BigInt.from(maxFeePerGas * pow(10, 9)).toRadixString(16)}";

    final maxPriorityFeePerGas = double.parse(
        jsonDecode(gasFeesResult)["result"]["high"]["maxPriorityFeePerGas"]);
    final maxPriorityFeePerGasHex =
        "0x${BigInt.from(maxPriorityFeePerGas * pow(10, 9)).toRadixString(16)}";

    // evm transaction
    final req = {
      "from": sender,
      "to": to,
      "gasLimit": gasLimit,
      "value": "0x0",
      "maxFeePerGas": maxFeePerGasHex,
      "maxPriorityFeePerGas": maxPriorityFeePerGasHex,
      "data": data,
      "type": "0x2",
      "nonce": "0x0",
      "chainId": "0x${TestAccount.evm.chainId.toRadixString(16)}",
    };
    //to hexString
    final reqStr = jsonEncode(req);
    final reqHex = utf8.encode(reqStr).map((e) => e.toRadixString(16)).join();

    return "0x$reqHex";
  }
}
