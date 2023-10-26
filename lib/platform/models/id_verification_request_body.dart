

import 'package:unified_checkout_sdk/network_manager/serializable.dart';

class IDVerificationBody implements Serializable{
  String mobileNumber;
  String idNumber;

  IDVerificationBody.create(this.mobileNumber, this.idNumber);

  @override
  Map<String, dynamic> toMap() {
    return {
      "PhoneNumber" : mobileNumber,
      "CardID" : idNumber
    };
  }
}