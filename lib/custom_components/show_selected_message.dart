
import 'package:unified_checkout_sdk/core_ui/app_rich_text.dart';
import 'package:unified_checkout_sdk/core_ui/dimensions.dart';
import 'package:unified_checkout_sdk/core_ui/text_style.dart';
import 'package:unified_checkout_sdk/platform/models/momo_provider.dart';
import 'package:flutter/material.dart';
import 'package:unified_checkout_sdk/resources/checkout_strings.dart';
Widget showSelectedProviderMessage({required MomoProvider selectedProvider}) {
  switch (selectedProvider.name) {
    case CheckoutStrings.mtnMobileMoney:
      return AppRichText(
        text: CheckoutStrings.paymentWithMomoInfoHead,
        fontSize: Dimens.body2,
        maxLines: 8,
        otherTexts: [
          TextSpan(
            text: CheckoutStrings.mtnMomoShortCode,
            style: AppTextStyle.body2().copyWith(fontWeight: FontWeight.bold),
          ),
          TextSpan(
              text: CheckoutStrings.paymentWithMomoInfoTail,
              style: AppTextStyle.body2()
          ),
        ],
      );
    case CheckoutStrings.vodafoneCash:
      return SizedBox();
    case CheckoutStrings.airtelTigoMoney:
      return SizedBox();
    default:
      return SizedBox();
  }
}