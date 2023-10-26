

// import 'package:unified_checkout_sdk/network_manager/serializable.dart';
import 'package:unified_checkout_sdk/platform/models/bank_card_data.dart';

import 'base_pref_manager.dart';
import 'pref_constants.dart';

class CheckoutPrefManager extends BasePrefManager{

  set mandateId(String value) {
    saveToSharedPref(PrefConstants.MANDATE_ID_KEY, value);
  }

  Future<String?> getMandateId() async {
    return await getSharedPrefString(PrefConstants.MANDATE_ID_KEY);
  }

  Future<void> saveBankWallet(BankCardData? card) async {
    saveToSharedPrefObject(PrefConstants.BANK_CARD_ID_KEY, card);
  }

}