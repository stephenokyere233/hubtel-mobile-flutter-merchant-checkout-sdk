import 'package:unified_checkout_sdk/network_manager/api_core.dart';
import 'package:unified_checkout_sdk/platform/models/add_mobile_wallet.dart';

import 'package:unified_checkout_sdk/platform/models/channel_fetch_response.dart';
import 'package:unified_checkout_sdk/platform/models/checkout_payment_status_response.dart';
import 'package:unified_checkout_sdk/platform/models/enroll_3ds_response.dart';
import 'package:unified_checkout_sdk/platform/models/mobile_money_request.dart';
import 'package:unified_checkout_sdk/platform/models/momo_response.dart';
import 'package:unified_checkout_sdk/platform/models/setup_payer_auth%20_response.dart';
import 'package:unified_checkout_sdk/platform/models/setup_payer_auth_request.dart';
import 'package:unified_checkout_sdk/platform/models/wallet.dart';

import '../../../network_manager/extensions/data_response.dart';
import '../../models/get_fees_response.dart';

class CheckoutApi extends ApiCore {
  CheckoutApi({required super.requester});

  Future<ResultWrapper<ChannelFetchResponse>> fetchChannels() async {
    final response = await requester.makeRequest(
      apiEndPoint: endPoints.checkoutEndPoint.fetchChannels(),
    );

    print("response here$response");
    final data = DataResponse<ChannelFetchResponse>.fromJson(
        response.response, (x) => ChannelFetchResponse.fromJson(x));

    return BaseApiResponse(response: data, apiResult: response.apiResult);
  }

  Future<ListResultWrapper<Wallet>> fetchWallets() async {
    final result = await requester.makeRequest(
        apiEndPoint: endPoints.checkoutEndPoint.fetchWallets()
    );
    final data = DataResponseList<Wallet>.fromJson(result.response, (x) => Wallet.fromJson(x));

    return BaseApiResponse(response: data, apiResult: result.apiResult);
  }

  Future<ResultWrapper<NewGetFeesResponse>> fetchFees(String channel, double amount) async {
    final result = await requester.makeRequest(
        apiEndPoint: endPoints.checkoutEndPoint.fetchFees(channel: channel, amount: amount)
    );
    final data = DataResponse<NewGetFeesResponse>.fromJson(result.response, (x) => NewGetFeesResponse.fromJson(x));

    return BaseApiResponse(response: data, apiResult: result.apiResult);
  }

  Future<ResultWrapper<MomoResponse>> payWithMomo({required MobileMoneyPaymentRequest req}) async {
    final result = await requester.makeRequest(
        apiEndPoint: endPoints.checkoutEndPoint.getReceiveMoneyEndpoint(req)
    );
    final data = DataResponse<MomoResponse>.fromJson(result.response, (x) => MomoResponse.fromJson(x));

    return BaseApiResponse(response: data, apiResult: result.apiResult);
  }

  Future<ResultWrapper<CheckoutOrderStatus>> checkStatus({required String clientReference}) async {
    final result = await requester.makeRequest(
        apiEndPoint: endPoints.checkoutEndPoint.checkStatus(clientReference: clientReference)
    );
    final data = DataResponse<CheckoutOrderStatus>.fromJson(result.response, (x) => CheckoutOrderStatus.fromJson(x));

    return BaseApiResponse(response: data, apiResult: result.apiResult);
  }

  Future<ResultWrapper<Setup3dsResponse>> setupDevice({required SetupPayerAuthRequest request}) async {
    final result = await requester.makeRequest(
        apiEndPoint: endPoints.checkoutEndPoint.setupDeviceForBankPayment(requestBody: request)
    );
    final data = DataResponse<Setup3dsResponse>.fromJson(result.response, (x) => Setup3dsResponse.fromJson(x));

    return BaseApiResponse(response: data, apiResult: result.apiResult);
  }

  Future<ResultWrapper<Enroll3dsResponse>> enroll({required String transactionId}) async {
    final result = await requester.makeRequest(
        apiEndPoint: endPoints.checkoutEndPoint.makeEnrollment(transactionId: transactionId)
    );
    final data = DataResponse<Enroll3dsResponse>.fromJson(result.response, (x) => Enroll3dsResponse.fromJson(x));

    return BaseApiResponse(response: data, apiResult: result.apiResult);
  }

  Future<ResultWrapper<Wallet>> addWallet({required AddMobileWalletBody req}) async {
    final result = await requester.makeRequest(
        apiEndPoint: endPoints.checkoutEndPoint.addMobileWallet(request: req)
    );
    final data = DataResponse<Wallet>.fromJson(result.response, (x) => Wallet.fromJson(x));

    return BaseApiResponse(response: data, apiResult: result.apiResult);
  }

}
