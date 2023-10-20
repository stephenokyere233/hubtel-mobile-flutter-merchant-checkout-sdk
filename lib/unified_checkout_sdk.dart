library unified_checkout_sdk;

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unified_checkout_sdk/core_ui/hubtel_colors.dart';
import 'package:unified_checkout_sdk/core_ui/text_style.dart';
import 'package:unified_checkout_sdk/platform/models/business_info.dart';

import 'package:unified_checkout_sdk/platform/models/channel_fetch_response.dart';
import 'package:unified_checkout_sdk/platform/models/checkout_requirements.dart';
import 'package:unified_checkout_sdk/platform/models/configuration_obj.dart';
import 'package:unified_checkout_sdk/platform/models/payment_status.dart';
import 'package:unified_checkout_sdk/platform/models/purchase_item.dart';
import 'package:unified_checkout_sdk/ux/checkout_screen.dart';
import 'package:unified_checkout_sdk/ux/checkout_screen2.dart';
import 'package:unified_checkout_sdk/ux/viewModel/checkout_view_model.dart';

import 'network_manager/extensions/uistate.dart';

enum CheckoutPaymentStatus { success, cancelled }

class CheckoutScreen extends StatefulWidget {
  final String? accessToken = '';

  late final Function(CheckoutPaymentStatus)? checkoutCompleted;

  late final PurchaseInfo purchaseInfo;

  late final HubtelCheckoutConfiguration configuration;

  late final ThemeConfig? themeConfig;

  late final viewModel = CheckoutViewModel();

  late final Function(PaymentStatus) onCheckoutComplete;

  Color? _primaryColor;

  CheckoutScreen({
    Key? key,
    required this.purchaseInfo,
    required this.configuration,
    this.checkoutCompleted,
    required this.onCheckoutComplete,
    this.themeConfig,
  }) : super(key: key) {
    CheckoutRequirements.customerMsisdn = purchaseInfo.customerMsisdn;
    CheckoutRequirements.apiKey = configuration.merchantApiKey;
    CheckoutRequirements.merchantId = configuration.merchantID;
    CheckoutRequirements.routeName = configuration.routeName;
  }

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void onNewCardInputComplete() async {}

  @override
  Widget build(BuildContext context) {
    // if (widget.themeConfig != null) {
    //   log(widget.themeConfig!.primaryColor.toString(), name: '$runtimeType');
    //   ThemeConfig.themeColor = widget.themeConfig!.primaryColor;
    // }

    log('${widget.themeConfig!.primaryColor}', name: '$runtimeType');
    ThemeConfig.themeColor = widget.themeConfig!.primaryColor;
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CheckoutViewModel())],
      child: Container(
        color: Colors.white,
        child: FutureBuilder<UiResult<ChannelFetchResponse>>(
          future: widget.viewModel.fetchChannels(),
          builder: (context,
              AsyncSnapshot<UiResult<ChannelFetchResponse>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                color: ThemeConfig.themeColor,
              ));
            } else {
              if (snapshot.hasData) {
                final businessInfo = snapshot.data?.data?.getBusinessInfo() ??
                    BusinessInfo(
                      businessName: 'businessName',
                      businessImageUrl: 'businessImageUrl',
                    );
                return CheckoutHomeScreen(
                  checkoutPurchase: widget.purchaseInfo,
                  businessInfo: businessInfo,
                  checkoutCompleted: widget.onCheckoutComplete,
                  themeConfig: widget.themeConfig ??
                      ThemeConfig(primaryColor: HubtelColors.teal),
                );
              }
            }
            return Center(
              child: CircularProgressIndicator(
                  color: ThemeConfig.themeColor, backgroundColor: Colors.teal[500]),
            );
          },
        ),
      ),
    );
  }

}
