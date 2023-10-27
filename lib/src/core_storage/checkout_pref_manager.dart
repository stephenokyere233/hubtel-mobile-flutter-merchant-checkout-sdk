import 'dart:developer';

import '../network_manager/network_manager.dart';
import '../platform/models/models.dart';
import 'base_pref_manager.dart';
import 'pref_constants.dart';

class CheckoutPrefManager extends BasePrefManager {
  set mandateId(String value) {
    saveToSharedPref(PrefConstants.MANDATE_ID_KEY, value);
  }

  Future<String?> getMandateId() async {
    return await getSharedPrefString(PrefConstants.MANDATE_ID_KEY);
  }

  Future<void> saveBankWallet(BankCardData? card) async {
    final List<Serializable> cards = List.unmodifiable([card]);
    saveToSharedPrefObjectList(PrefConstants.BANK_CARD_ID_KEY, cards);
  }

  Future<List<BankCardData>?> getBankCards() async {
    final list = await getSharedPrefObjectList(PrefConstants.BANK_CARD_ID_KEY);
    return list?.map((e) => BankCardData.fromJson(e)).toList();
  }

  Future<List<BankCardData>>? getCards() async {
    final parsedJson =
        await getSharedPrefObjectList(PrefConstants.BANK_CARD_ID_KEY);
    if (parsedJson == null) return [];
    return parsedJson.map((e) => BankCardData.fromJson(e)).toList();
  }

  Future<void> printCards() async {
    final list = await getSharedPrefObjectList(PrefConstants.BANK_CARD_ID_KEY);
    list?.forEach((element) {
      log('$element', name: '$runtimeType');
    });
  }
}
