

import 'package:unified_checkout_sdk/network_manager/api_core.dart';
import 'package:unified_checkout_sdk/network_manager/endpoint_core.dart';
import 'package:unified_checkout_sdk/network_manager/requester.dart';
import 'package:unified_checkout_sdk/platform/models/add_mobile_wallet.dart';
import 'package:unified_checkout_sdk/platform/models/id_verification_request_body.dart';
import 'package:unified_checkout_sdk/platform/models/mobile_money_request.dart';
import 'package:unified_checkout_sdk/platform/models/otp_verify_request_body.dart';
import 'package:unified_checkout_sdk/platform/models/setup_payer_auth_request.dart';
import 'package:unified_checkout_sdk/utils/currency_formatter.dart';

class CheckoutEndPoint with EndPointCore {
  final _basePath = "checkout.hubtel.com";

  @override
  set apiKey(String apiKey) {
    // TODO: implement apiKey
    super.apiKey = apiKey;
  }

  final String merchantId;

  final String customerMsisdn;

  CheckoutEndPoint(
      {required this.merchantId,
      required this.customerMsisdn,
      required String apiKey}) {
    this.apiKey = apiKey;
  }

  Future<ApiEndPoint> getReceiveMoneyEndpoint(
      MobileMoneyPaymentRequest request) {
    return createEndpoint(
        authority: _basePath,
        path:
            "/api/v1/merchant/$merchantId/unifiedcheckout/receive/mobilemoney/prompt",
        requestType: HttpVerb.POST,
        body: request.toMap());
  }

  Future<ApiEndPoint> getDirectDebitEndPoint(
      MobileMoneyPaymentRequest request) {
    return createEndpoint(
        authority: _basePath,
        path:
            "/api/v1/merchant/$merchantId/unifiedcheckout/receive/mobilemoney/directdebit",
        requestType: HttpVerb.POST,
        body: request.toMap());
  }

  Future<ApiEndPoint> getPreApprovalConfirmEndPoint(
      MobileMoneyPaymentRequest request) {
    return createEndpoint(
        authority: _basePath,
        path: "",
        requestType: HttpVerb.POST,
        body: request.toMap());
  }

  Future<ApiEndPoint> fetchChannels() {
    return createEndpoint(
      authority: _basePath,
      path: "api/v1/merchant/$merchantId/unifiedcheckout/checkoutchannels",
      requestType: HttpVerb.GET,
    );
  }

  Future<ApiEndPoint> fetchWallets() {
    return createEndpoint(
        authority: _basePath,
        path:
            "api/v1/merchant/$merchantId/unifiedcheckout/wallets/$customerMsisdn",
        requestType: HttpVerb.GET);
  }

  Future<ApiEndPoint> fetchFees(
      {required String channel, required double amount}) {
    return createEndpoint(
        authority: _basePath,
        path: "api/v1/merchant/$merchantId/unifiedcheckout/feecalculation",
        requestType: HttpVerb.GET,
        body: {
          "ChannelPassed": channel,
          "amount": amount.formatDoubleToString()
        });
  }

  Future<ApiEndPoint> checkStatus({required String clientReference}) {
    return createEndpoint(
        authority: _basePath,
        path: "api/v1/merchant/$merchantId/unifiedcheckout/statuscheck",
        requestType: HttpVerb.GET,
        body: {"clientReference": clientReference});
  }

  Future<ApiEndPoint> setupDeviceForBankPayment(
      {required SetupPayerAuthRequest requestBody}) {
    return createEndpoint(
        authority: _basePath,
        path: "api/v1/merchant/$merchantId/cardnotpresent/setup-payerauth",
        requestType: HttpVerb.POST,
        body: requestBody.toMap());
  }

  Future<ApiEndPoint> makeEnrollment({required String transactionId}) {
    return createEndpoint(
        authority: _basePath,
        path:
            "api/v1/merchant/$merchantId/cardnotpresent/enroll-payerauth/$transactionId",
        requestType: HttpVerb.GET);
  }

  Future<ApiEndPoint> addMobileWallet({required AddMobileWalletBody request}) {
    return createEndpoint(
        authority: _basePath,
        path: "api/v1/merchant/$merchantId/unifiedcheckout/addwallet",
        requestType: HttpVerb.POST,
        body: request.toMap());
  }

  Future<ApiEndPoint> checkUserVerification({required String mobileNumber}) {
    return createEndpoint(
      authority: _basePath,
      path:
          "api/v1/merchant/$merchantId/ghanacardkyc/ghanacard-details/$mobileNumber",
      requestType: HttpVerb.GET,
    );
  }

  Future<ApiEndPoint> confirmCardDetails() {
    return createEndpoint(
      authority: _basePath,
      path: "/api/v1/merchant/$merchantId/ghanacardkyc/confirm-ghana-card",
      requestType: HttpVerb.POST,
    );
  }

  Future<ApiEndPoint> intakeUserInput({required IDVerificationBody params}) {
    return createEndpoint(
        authority: _basePath,
        path: "api/v1/merchant/$merchantId/ghanacardkyc/addghanacard",
        requestType: HttpVerb.GET,
        body: params.toMap());
  }

  Future<ApiEndPoint> otpVerification({required OtpBodyRequest request}) {
    return createEndpoint(
        authority: _basePath,
        path: "api/v1/merchant/$merchantId/unifiedcheckout/verifyotp",
        requestType: HttpVerb.POST,
        body: request.toMap()
    );
  }
}
