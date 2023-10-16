library unified_checkout_sdk;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unified_checkout_sdk/platform/models/business_info.dart';

import 'package:unified_checkout_sdk/platform/models/channel_fetch_response.dart';
import 'package:unified_checkout_sdk/platform/models/checkout_requirements.dart';
import 'package:unified_checkout_sdk/platform/models/configuration_obj.dart';
import 'package:unified_checkout_sdk/platform/models/payment_status.dart';
import 'package:unified_checkout_sdk/platform/models/purchase_item.dart';
import 'package:unified_checkout_sdk/ux/checkout_screen.dart';
import 'package:unified_checkout_sdk/ux/viewModel/checkout_view_model.dart';
// import 'package:webview_flutter/webview_flutter.dart';

import 'network_manager/extensions/uistate.dart';

enum CheckoutPaymentStatus { success, cancelled }

class CheckoutScreen extends StatefulWidget {
  String? accessToken;

  // final CheckoutConfig checkoutConfig;
  Function(CheckoutPaymentStatus)? checkoutCompleted;

  PurchaseInfo purhaseInfo;

  HubtelCheckoutConfiguration configuration;

  late final viewModel = CheckoutViewModel();

  Function(PaymentStatus) onCheckoutComplete;

  CheckoutScreen(
      {Key? key,
      required this.purhaseInfo,
      required this.configuration,
      this.checkoutCompleted,
      required this.onCheckoutComplete
      })
      : super(key: key) {
    CheckoutRequirements.customerMsisdn = purhaseInfo.customerMsisdn;
    CheckoutRequirements.apiKey = configuration.merchantApiKey;
    CheckoutRequirements.merchantId = configuration.merchantID;
    CheckoutRequirements.routeName = configuration.routeName;
  }

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // late CheckoutViewModel viewModel;
  // late final WebViewController controller;

  // List<Wallet> wallets = [];
  // List<MomoProvider> providers = [
  //   MomoProvider(name: CheckoutStrings.mtnMobileMoney, alias: CheckoutStrings.mtn),
  //   MomoProvider(name: CheckoutStrings.airtelTigoMoneyString, alias: CheckoutStrings.tigoGh),
  //   MomoProvider(name: CheckoutStrings.vodafoneCash, alias: CheckoutStrings.vodafone)
  // ];

  // List<CheckoutFee> checkoutFees = [];
  //
  // MomoProvider? selectedProvider;

  // Wallet? ebankWallet;
  //
  // CardData? selectedSavedCard;
  // Setup3dsResponse? threedsResponse;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // Future<void> _getWallets() async {
  //   await viewModel.getWallets();
  //   await viewModel.getHubtelBalance();
  //
  //   final momoWallets = await viewModel.getMomoWallets();
  //   setState(() {
  //     wallets = momoWallets ?? [];
  //   });
  // }

  void onNewCardInputComplete() async {
    // final isCardNumberInputComplete = cardNumberInputController.text.trim().isNotEmpty &&
    //     cardNumberInputController.text.characters.length == 22;
    //
    // final isCardDateInputComplete =
    //     cardDateInputController.text.trim().isNotEmpty && cardDateInputController.text.length == 5;
    //
    // final isCardCvvInputComplete =
    //     cardCvvInputController.text.trim().isNotEmpty && cardCvvInputController.text.length == 3;
    //
    // if (isCardNumberInputComplete && isCardDateInputComplete && isCardCvvInputComplete) {
    //   final channel = viewModel.getCardChannelName(newCardNumber);
    //   final feeSum = await computeCheckoutFeeSum(channel);
    //   final purchaseAmount =
    //       widget.checkoutConfig.checkoutPurchase.instantServicePurchase?.amount ?? 0.00;
    //
    //   setState(() {
    //     totalAmountPayable = purchaseAmount + feeSum;
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CheckoutViewModel())],
      child: Container(
        color: Colors.white,
        child: FutureBuilder<UiResult<ChannelFetchResponse>>(
          future: widget.viewModel.fetchChannels(),
          builder: (context,
              AsyncSnapshot<UiResult<ChannelFetchResponse>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.hasData) {
                final businessInfo = snapshot.data?.data?.getBusinessInfo() ??
                    BusinessInfo(
                        businessName: "businessName",
                        businessImageUrl: "businessImageUrl");
                return CheckoutHomeScreen(
                    checkoutPurchase: widget.purhaseInfo,
                    businessInfo: businessInfo,
                  checkoutCompleted: widget.onCheckoutComplete,
                );
              }
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  Future<String> fetchData() async {
    // Simulate an API request (Replace with your actual API call)
    await Future.delayed(Duration(seconds: 2));
    return "Hello, FutureBuilder!";
  }

// Future<void> onHubtelWalletExpansionChanged(bool value) async {
//   if (value == true) {
//     setState(() {
//       isMobileMoneyExpanded = false;
//       walletType = WalletType.Hubtel;
//     });
//     hubtelWalletExpansionController.expand();
//     bankCardExpansionController.collapse();
//     mobileMoneyExpansionController.collapse();
//     // AnalyticsHelper.logEvent(event: AppEvent.choose_checkout_payment_method);
//
//     final feeSum = await computeCheckoutFeeSum('hubtel-gh');
//     final purchaseAmount =
//         widget.checkoutConfig.checkoutPurchase.instantServicePurchase?.amount ?? 0.00;
//
//     setState(() {
//       totalAmountPayable = purchaseAmount + feeSum;
//     });
//   }
// }

// Future<void> onMomoTileExpansionChanged(bool value) async {
//   if (value == true && !didPreSelectMomoWallet) {
//     preselectMomoWallet();
//     setState(() {
//       didPreSelectMomoWallet = true;
//     });
//   }
//
//   if (value == true) {
//     setState(() {
//       isMobileMoneyExpanded = true;
//       walletType = WalletType.Momo;
//     });
//     mobileMoneyExpansionController.expand();
//     bankCardExpansionController.collapse();
//     hubtelWalletExpansionController.collapse();
//
//     final channel = viewModel.getMomoChannelName(selectedProvider?.name);
//     final feeSum = await computeCheckoutFeeSum(channel);
//     final purchaseAmount =
//         widget.checkoutConfig.checkoutPurchase.instantServicePurchase?.amount ?? 0.00;
//
//     setState(() {
//       totalAmountPayable = purchaseAmount + feeSum;
//     });
//   }
// }

// Future<double> computeCheckoutFeeSum(String channel) async {
//   final instantServicesPurchase = widget.checkoutConfig.checkoutPurchase.instantServicePurchase;
//   setState(() => isLoadingFees = true);
//
//   final result = await viewModel.getSendMoneyCheckoutFees(
//     instantServicesPurchase,
//     channel,
//   );
//
//   checkoutFees = result.data ?? [];
//   final checkoutFeeSum = checkoutFees.fold(
//     0.00,
//         (prevValue, fee) => prevValue + (fee.feeAmount ?? 0.0),
//   );
//
//   setState(() => isLoadingFees = false);
//
//   return checkoutFeeSum ?? 0.00;
// }

// showCancelDialog() {
//   return CancelDialog(
//     title: CheckoutStrings.cancelTransaction,
//     approveButtonText: CoreStrings.noText,
//     cancelButtonText: CoreStrings.yesText,
//     orientation: CancelDialogButtonsOrientation.horizontal,
//     onApprove: () {
//       Navigator.pop(context);
//     },
//     onCancel: () {
//       Navigator.of(context)
//         ..popUntil((route) => route.isFirst)
//         ..pushNamed(widget.checkoutConfig.fallbackRoute);
//     },
//     description: CheckoutStrings.doYouWantToCancelTransaction,
//   );
// }

// HubtelOrder _getOrder() {
//   switch (widget.checkoutConfig.checkoutPurchase.checkoutType) {
//     case CartOption.instantService:
//       return widget.checkoutConfig.checkoutPurchase.instantServicePurchase?.toHubtelOrder() ??
//           HubtelOrder();
//       return widget.checkoutPurchase.instantServicePurchase
//               ?.toHubtelOrder() ??
//           HubtelOrder();
//     default:
//       return HubtelOrder();
//   }
// }

// bool shouldEnablePayButton() {
//   if (walletType == null) return false;
//   if (walletType == WalletType.Card) {
//     return cardNumberInputController.text.isNotEmpty &&
//         cardCvvInputController.text.isNotEmpty &&
//         cardDateInputController.text.isNotEmpty;
//   }
//   return true;
// }

// void payNow() async {
//   if (isLoadingFees) return;
//
//   switch (walletType) {
//     case WalletType.Card:
//       if (widget.checkoutConfig.checkoutPurchase.checkoutType == CartOption.instantService) {
//         _checkoutInstantServiceWithBankCard();
//       }
//     case WalletType.Hubtel:
//       _checkoutWithHubtelWallet();
//     case WalletType.Momo:
//       if (widget.checkoutConfig.checkoutPurchase.checkoutType == CartOption.instantService) {
//         _checkoutInstantServiceWithMomo();
//       }
//     default:
//       break;
//   }
// }

// void _checkoutWithHubtelWallet() async {
//   selectedWallet = await viewModel.getHubtelWallet();
//   if (context.mounted) {
//     _checkIfUserSetPin(context);
//   }
// }

// void autoSelectProviderFromSelectedWallet() {
//   setState(() {
//     momoProviderController.text = CheckoutUtils.mapApiWalletProviderNameToKnowName(
//         providerName: selectedWallet?.provider ?? "");
//     selectedProvider = MomoProvider(
//       name: CheckoutUtils.mapApiWalletProviderNameToKnowName(
//         providerName: selectedWallet?.provider ?? "",
//       ),
//     );
//   });
// }

// void preselectMomoWallet() {
//   if (wallets.isNotEmpty) {
//     setState(() {
//       selectedWallet = wallets[0];
//       mobileNumberController.text = selectedWallet?.accountNo ?? "";
//       momoProviderController.text = CheckoutUtils.mapApiWalletProviderNameToKnowName(
//           providerName: selectedWallet?.provider ?? "");
//       selectedProvider = MomoProvider(
//         name: CheckoutUtils.mapApiWalletProviderNameToKnowName(
//           providerName: selectedWallet?.provider ?? "",
//         ),
//       );
//     });
//   }
// }

// _checkoutInstantServiceWithMomo() async {
//   _momoAndHubtelWalletCheckoutSetup(onCheckoutComplete: (hubtelServiceOrder) {
//     widget.showPromptDialog(
//         context: context,
//         title: CheckoutStrings.success,
//         buttonTitle: CoreStrings.okayText,
//         subtitle: CheckoutStrings.getPaymentPromptMessage(
//             walletNumber: selectedWallet?.accountNo ?? ""),
//         buttonAction: () {
//           Navigator.pop(context);
//           // Goto Transaction Status Screen
//           CheckoutNavigation.Navigation().gotoPaymentStatus(
//             context,
//             checkoutConfig:
//             widget.checkoutConfig.copyWith(hubtelServiceOrder: hubtelServiceOrder),
//           );
//         });
//   });
// }

// _momoAndHubtelWalletCheckoutSetup({
//   required Function(HubtelServiceOrder?) onCheckoutComplete,
// }) async {
//   final instantServiceRequest = widget.checkoutConfig.checkoutPurchase.instantServicePurchase
//       ?.toInstantServiceCheckoutRequest(
//     wallet: selectedWallet ?? Wallet(),
//   );
//
//   if (walletType == WalletType.Momo) {
//     selectedWallet?.provider = selectedProvider?.alias;
//   }
//
//   print(selectedWallet.toString());
//
//   widget.showLoadingDialog(context: context, text: CheckoutStrings.pleaseWait);
//   final response = await viewModel.checkoutInstantService(
//     instantServiceRequest ?? InstantServiceCheckoutRequest(),
//   );
//
//   if (!mounted) return;
//   widget.dismissDialog(context: context);
//
//   if (response.state == UiState.success) {
//     onCheckoutComplete.call(response.data?.order);
//   } else {
//     widget.showErrorDialog(
//       context: context,
//       message: response.message,
//     );
//   }
// }

// _checkoutInstantServiceWithBankCard() async {
//   final bankWallet = Wallet.createBankWallet(
//     accountNumber: newCardNumber ?? "",
//     cvv: newCardCvv ?? "",
//     expiry: newCardExpiry ?? "",
//   );
//   ebankWallet = bankWallet;
//
//   final dsRequest = bankWallet.toSetup3dsRequest();
//
//   widget.showLoadingDialog(
//     context: context,
//     text: CheckoutStrings.pleaseWait,
//   );
//
//   final apiResult = await viewModel.setup3ds(dsRequest);
//
//   if (!context.mounted) return;
//
//   if (apiResult.state == UiState.success) {
//     widget.accessToken = apiResult.data?.accessToken;
//     threedsResponse = apiResult.data ?? Setup3dsResponse();
//
//     setState(() {
//       showWebView = true;
//
//       controller.loadHtmlString(
//         CheckoutStrings.makeHtmlString(
//           widget.accessToken ?? "",
//         ),
//       );
//     });
//   } else {
//     widget.dismissDialog(context: context);
//
//     widget.showErrorDialog(
//       context: context,
//       message: apiResult.message,
//     );
//   }
// }

// _checkoutInstantService() async {
//   final instantServicePurchaseRequest = widget
//       .checkoutConfig.checkoutPurchase.instantServicePurchase
//       ?.toInstantServiceCheckoutRequest(
//       wallet: ebankWallet ?? Wallet(), setup3dsResponse: threedsResponse);
//
//   final checkoutResponse = await viewModel
//       .checkoutInstantService(instantServicePurchaseRequest ?? InstantServiceCheckoutRequest());
//
//   if (!mounted) return;
//
//   if (checkoutResponse.state == UiState.success) {
//     viewModel.cardCheckoutCompletionStatus =
//         CardCheckoutCompletionStatus(orderId: checkoutResponse.data?.order?.id ?? "");
//     viewModel.cardCheckoutCompletionStatus = CardCheckoutCompletionStatus(
//       orderId: checkoutResponse.data?.order?.id ?? "",
//     );
//
//     Navigator.pop(context);
//     final cardCheckoutStatus = await AppNavigator.navigateTo(
//       context,
//       Navigation.webCheckout,
//       arguments: WebCheckoutPageData(
//         jwt: checkoutResponse.data?.cardStepUpJwt ?? "",
//         orderId: checkoutResponse.data?.order?.id ?? "",
//         reference: threedsResponse?.referenceId ?? "",
//         customData: checkoutResponse.data?.cardCustomData,
//       ),
//     );
//
//     onCardCheckoutComplete(
//       cardCheckoutStatus,
//       checkoutResponse.data?.order,
//     );
//   } else {
//     widget.showErrorDialog(
//       context: context,
//       message: checkoutResponse.message,
//     );
//   }
// }

// onCardCheckoutComplete(
//     CardCheckoutCompletionStatus status,
//     HubtelServiceOrder? hubtelServiceOrder,
//     ) {
//   if (status.isComplete == true) {
//     CheckoutNavigation.Navigation().gotoPaymentStatus(
//       context,
//       checkoutConfig: widget.checkoutConfig.copyWith(
//         hubtelServiceOrder: hubtelServiceOrder,
//       ),
//     );
//   }
// }

// void _checkIfUserSetPin(BuildContext context) async{
//   final hasSetPin = await viewModel.getHasSetPin();
//   print(hasSetPin);
//   if (hasSetPin ?? false){
//     _showModal(context);
//   }else{
//     if (!mounted) return;
//     showDialog(context: context, builder: (context) => _showInfoDialog());
//   }
// }

// void _showModal(BuildContext context) async {
//
//
//   final hasSetPin = viewModel.getCustomerMsisdn();
//
//   final result = await showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     builder: (BuildContext context) {
//       return ScreenLockScreen();
//     },
//   );
//
//   if (result != null) {
//     final isPinComplete = result as bool;
//     if (isPinComplete) {
//       _momoAndHubtelWalletCheckoutSetup(
//         onCheckoutComplete: (hubtelServiceOrder) {
//           CheckoutNavigation.Navigation().gotoPaymentStatus(
//             context,
//             checkoutConfig: widget.checkoutConfig.copyWith(
//               hubtelServiceOrder: hubtelServiceOrder,
//             ),
//           );
//         },
//       );
//     }
//   }
// }

// _showInfoDialog() {
//   return HBPrimaryDialog(
//     title: CheckoutStrings.secureHubtelPin,
//     message: CheckoutStrings.secureHubtelPinMessage,
//     buttonTitle: CheckoutStrings.okay,
//     imageWidget:Image(
//       height: 64,
//       width: 64,
//       image: AssetImage(CoreDrawables.incompleteIcon),
//
//     ),
//     buttonAction: () async {
//       Navigator.pop(context);
//       final result = await showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         builder: (BuildContext context) {
//           return const SetPinScreen();
//         },
//       );
//
//       if (result != null) {
//         final isPinComplete = result as bool;
//         if(isPinComplete){
//           _showModal(context);
//         }
//       }
//     },
//   );
// }
}
