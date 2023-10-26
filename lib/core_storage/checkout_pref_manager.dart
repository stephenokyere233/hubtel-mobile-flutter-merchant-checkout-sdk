

import 'base_pref_manager.dart';
import 'pref_constants.dart';

class CheckoutPrefManager extends BasePrefManager{

  set mandateId(String value) {
    saveToSharedPref(PrefConstants.MANDATE_ID_KEY, value);
  }

  Future<String?> getMandateId() async {
    return await getSharedPrefString(PrefConstants.MANDATE_ID_KEY);
  }

}