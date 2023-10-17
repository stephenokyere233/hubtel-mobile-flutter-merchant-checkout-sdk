import 'package:flutter/material.dart';
import 'package:unified_checkout_sdk/resources/dimens.dart';

import 'checkout_colors.dart';
import 'checkout_strings.dart';
import 'fonts.dart';

class Styles {
  Styles._();

  static const TextStyle cardInfoStyle = TextStyle(
    color: CheckoutColors.defaultBlackColor,
    fontSize: Dimens.fontMedium,
    fontWeight: FontWeight.w800,
    fontStyle: FontStyle.normal,
    fontFamily: CheckoutFonts.nunitoSans,
    package: CheckoutStrings.package,
  );

  static const TextStyle cardLabelStyle = TextStyle(
    fontSize: Dimens.fontSmall,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w400,
    fontFamily: CheckoutFonts.nunitoSans,
    package: CheckoutStrings.package,
  );

  static const TextStyle appBarTextStyle = TextStyle(
    fontFamily: CheckoutFonts.nunitoSans,
    package: CheckoutStrings.package,
    // fontSize: Dimens.fontMedium,
    fontSize: Dimens.fontLarge,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w400,
    color: CheckoutColors.titleColor,
  );

  static const TextStyle appBarTextStyle2 = TextStyle(
    fontFamily: CheckoutFonts.nunitoSans,
    package: CheckoutStrings.package,
    // fontSize: Dimens.fontMedium,
    fontSize: Dimens.fontLarge,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.bold,
    color: CheckoutColors.titleColor,
  );

  static const TextStyle confirmTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontFamily: CheckoutFonts.nunitoSans,
      fontStyle: FontStyle.normal,
      fontSize: 14.0);

  static const TextStyle orderTextStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontFamily: CheckoutFonts.nunitoSans,
      fontStyle: FontStyle.normal,
      fontSize: 14.0);

  static const cardDetailsTextStyle = TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 14.0,
  );
}