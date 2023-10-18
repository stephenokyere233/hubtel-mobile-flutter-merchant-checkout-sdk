import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unified_checkout_sdk/core_ui/dimensions.dart';
import 'package:unified_checkout_sdk/core_ui/hubtel_colors.dart';
import 'package:unified_checkout_sdk/core_ui/text_style.dart';
import 'package:unified_checkout_sdk/custom_components/custom_indicator.dart';
import 'package:unified_checkout_sdk/custom_components/mobile_money_tile_field.dart';
import 'package:unified_checkout_sdk/platform/models/wallet.dart';
import 'package:unified_checkout_sdk/resources/checkout_strings.dart';
import 'package:unified_checkout_sdk/utils/currency_formatter.dart';
import 'package:unified_checkout_sdk/utils/custom_expansion_widget.dart'
    as customExpansion;

enum OtherAccountTypes {
  Hubtel("Hubtel"),
  GMoney("GMoney"),
  Zeepay("Zeepay");

  final String rawValue;

  const OtherAccountTypes(this.rawValue);
}

class OtherPaymentExpansionTile extends StatefulWidget {
  final TextEditingController editingController;

  final TextEditingController anotherEditingController;

  bool expandOptions = false;

  bool showHubtelWalletActions = false;

  bool showGmoneyWalletActions = false;

  bool showZeePayWalletActions = false;

  String selectedAccount = "Hubtel";

  Function(Wallet) onWalletSelected;

  Function(String) onChannelChanged;

  List<Wallet> wallettypes = [
    Wallet(
        externalId: "0011",
        accountNo: "0556236739",
        accountName: "Hubtel",
        providerId: "providerId",
        provider: "provider",
        type: "type"),
    Wallet(
        externalId: "0011",
        accountNo: "0556236739",
        accountName: "GMoney",
        providerId: "providerId",
        provider: "provider",
        type: "type"),
    Wallet(
        externalId: "0011",
        accountNo: "0556236739",
        accountName: "Zeepay",
        providerId: "providerId",
        provider: "provider",
        type: "type"),
  ];

  List<Wallet> wallets;

  OtherPaymentExpansionTile(
      {Key? key,
      required this.controller,
      required this.onExpansionChanged,
      required this.editingController,
      required this.isSelected,
        required this.wallets,
        required this.onWalletSelected,
        required this.anotherEditingController,
        required this.onChannelChanged
      })
      : super(key: key);

  final customExpansion.ExpansionTileController controller;
  final void Function(bool)? onExpansionChanged;
  final bool isSelected;

  // final double value;

  @override
  State<OtherPaymentExpansionTile> createState() =>
      _OtherPaymentExpansionTileState();
}

class _OtherPaymentExpansionTileState extends State<OtherPaymentExpansionTile> {
  // List<String> bankCardTypeTabNames = [
  //   CheckoutStrings.useNewCard,
  //   CheckoutStrings.useSavedCard
  // ];

  // @override
  // void initState() {
  //   super.initState();
  //   autoSelectFirstWallet();
  // }

  @override
  Widget build(BuildContext context) {
    // onPaymentTypeChanged(selectedAccount: widget.selectedAccount);
    return customExpansion.ExpansionTile(
      controller: widget.controller,
      headerBackgroundColor:
          widget.isSelected ? HubtelColors.teal.shade100 : Colors.transparent,
      onExpansionChanged: widget.onExpansionChanged,
      maintainState: true,
      title: Text(
        CheckoutStrings.other,
        style: AppTextStyle.body2(),
      ),
      expandedAlignment: Alignment.topLeft,
      childrenPadding: const EdgeInsets.symmetric(
        horizontal: Dimens.paddingDefault,
        vertical: Dimens.paddingDefault,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text("sd"),
          // SizedBox(
          //   width: 8,
          // ),
          // Text("sd"),
          // SizedBox(
          //   width: 8,
          // ),
          // Text("sd"),
        ],
      ),
      leading: CustomRadioIndicator(
        isSelected: widget.isSelected,
      ),
      leadingWidth: Dimens.iconMedium,
      titleAlignment: ListTileTitleAlignment.center,
      //TODO: CHECK WHY STATE NOT UPDATING
      children: [
        MobileMoneyTileField(
            showWalletAdditionTile: false,
            fieldController: widget.editingController,
            wallets: widget.wallettypes,
            onWalletSelected: (wallet) {
              _onPaymentTypeChanged(selectedAccount: wallet.accountName ?? "");
              widget.onChannelChanged("hghgf ");

            },
            onProviderSelected: (provider) {
              print(provider);
            },
            hintText: "Hubtel"),
        
        Visibility(
            visible: widget.showHubtelWalletActions,
            child: Container(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "Your balance Hubtel will be debited immediately you confirm. \n\nNo authorzation prompt will be sent to you",
                  textAlign: TextAlign.start,
                ),
              ),
            )),
        Visibility(
            visible: widget.showGmoneyWalletActions ||
                widget.showZeePayWalletActions,
            child: Padding(
              padding: EdgeInsets.only(top: 16),
              child: MobileMoneyTileField(
                  fieldController: widget.anotherEditingController,
                  wallets: widget.wallets,
                  onWalletSelected: (wallet) {
                    widget.onWalletSelected(wallet);
                  },
                  onProviderSelected: (provider) {
                    print(provider);
                  },
                  hintText: "Hinting"),
            )),
        Visibility(
          visible: widget.showGmoneyWalletActions,
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Checkbox(
                value: true, onChanged: (value) {}
            )
            ,
            Text("Use Mandate ID")
          ]),
        ),
        Visibility(
            visible: widget.showGmoneyWalletActions,
            child: Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                  "You will be required to enter your Mandate ID to confirm your transaction"),
            )),
        Visibility(
            visible: widget.showZeePayWalletActions,
            child: Container(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Steps to authorize payment", style: AppTextStyle.body2().copyWith(fontWeight: FontWeight.bold),),
                    Text("1. Dial *270#",style: AppTextStyle.body2(),),
                    Text("2. Select Option 8 (Account)", style: AppTextStyle.body2(),),
                    Text("3. Select Option 4 (Approve Payment)", style: AppTextStyle.body2(),),
                    Text("4. Enter Pin to make Payment", style: AppTextStyle.body2(),),
                  ],
                ),
              ),
            ))
      ],
    );
  }

  _onPaymentTypeChanged({required String selectedAccount}) {

    //
    if (OtherAccountTypes.Hubtel.rawValue == selectedAccount) {

      setState(() {
        // widget.selectedAccount = "Hubtel";
        widget.showHubtelWalletActions = true;
        widget.showGmoneyWalletActions = false;
        widget.showZeePayWalletActions = false;

      });

      return;
    }

    if (OtherAccountTypes.GMoney.rawValue == selectedAccount) {

      setState(() {
        // widget.selectedAccount = "GMoney";
        widget.showHubtelWalletActions = false;
        widget.showGmoneyWalletActions = true;
        widget.showZeePayWalletActions = false;
      });
      return;
    }

    if (OtherAccountTypes.Zeepay.rawValue == selectedAccount) {

      setState(() {
        // selectedAccount = "Zeepay";
        widget.showHubtelWalletActions = false;
        widget.showGmoneyWalletActions = false;
        widget.showZeePayWalletActions = true;
      });

      return;
    }

  }
}


