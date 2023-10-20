



import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unified_checkout_sdk/core_ui/app_image_widget.dart';
import 'package:unified_checkout_sdk/core_ui/dimensions.dart';
import 'package:unified_checkout_sdk/core_ui/hubtel_colors.dart';
import 'package:unified_checkout_sdk/core_ui/text_style.dart';
import 'package:unified_checkout_sdk/custom_components/custom_indicator.dart';
import 'package:unified_checkout_sdk/custom_components/mobile_money_tile_field.dart';
import 'package:unified_checkout_sdk/platform/models/wallet.dart';
import 'package:unified_checkout_sdk/resources/checkout_drawables.dart';
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

class BankPayExpansionTile extends StatefulWidget {

  BankPayExpansionTile(
      {Key? key,
        required this.controller,
        required this.onExpansionChanged,
        required this.isSelected,
      })
      : super(key: key);

  final customExpansion.ExpansionTileController controller;
  final void Function(bool)? onExpansionChanged;
  final bool isSelected;

  // final double value;

  @override
  State<BankPayExpansionTile> createState() =>
      _BankPayExpansionTileState();
}

class _BankPayExpansionTileState extends State<BankPayExpansionTile> {

  @override
  Widget build(BuildContext context) {
    return customExpansion.ExpansionTile(
      controller: widget.controller,
      headerBackgroundColor:
      widget.isSelected ? ThemeConfig.themeColor.withOpacity(0.3) : Colors.transparent,
      onExpansionChanged: widget.onExpansionChanged,
      maintainState: true,
      title: Text(
        CheckoutStrings.bank_pay,
        style: AppTextStyle.body2(),
      ),
      expandedAlignment: Alignment.topLeft,
      // childrenPadding: const EdgeInsets.symmetric(
      //   horizontal: Dimens.paddingDefault,
      //   vertical: Dimens.paddingDefault,
      // ),
      trailing:  Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppImageWidget.local(
          image: const AssetImage(CheckoutDrawables.bankPay),
          width: Dimens.seventyFive,
          height: Dimens.seventyFive,
          boxFit: BoxFit.contain,
          borderRadius: 0,
        )],
      ),
      leading: CustomRadioIndicator(
        isSelected: widget.isSelected,
      ),
      leadingWidth: Dimens.iconMedium,
      titleAlignment: ListTileTitleAlignment.center,
    );
  }


}


