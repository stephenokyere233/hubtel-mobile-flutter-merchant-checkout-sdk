import 'package:unified_checkout_sdk/network_manager/checkout_endpoints.dart';
import 'package:unified_checkout_sdk/platform/models/checkout_requirements.dart';

class EndPoints {
  CheckoutEndPoint get checkoutEndPoint => CheckoutEndPoint(
        merchantId: CheckoutRequirements.merchantId,
        apiKey: CheckoutRequirements.apiKey,
        customerMsisdn: CheckoutRequirements.customerMsisdn
      );
}
