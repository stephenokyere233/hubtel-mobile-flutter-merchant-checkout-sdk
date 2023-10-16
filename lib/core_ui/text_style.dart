
import 'package:flutter/material.dart';
import 'package:unified_checkout_sdk/core_ui/dimensions.dart';
import 'package:unified_checkout_sdk/core_ui/hubtel_colors.dart';

const TextStyle _baseTextStyle = TextStyle(
  fontFamily: "NunitoSans",
);

class AppTextStyle {
  static TextStyle headline1() {
    return _baseTextStyle.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: Dimens.h1,
      color: HubtelColors.black,
    );
  }

  static TextStyle headline2() {
    return _baseTextStyle.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: Dimens.h2,
      color: Colors.black,
    );
  }

  static TextStyle headline3() {
    return _baseTextStyle.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: Dimens.h3,
      color: Colors.black,
    );
  }

  static TextStyle headline4() {
    return _baseTextStyle.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: Dimens.h4,
      color: Colors.black,
    );
  }

  static TextStyle headline5() {
    return _baseTextStyle.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: Dimens.h5,
      color: Colors.black,
    );
  }

  static TextStyle headline6() {
    return _baseTextStyle.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: Dimens.h6,
      color: Colors.black,
    );
  }

  static TextStyle body1() {
    return _baseTextStyle.copyWith(
      fontWeight: FontWeight.normal,
      fontSize: Dimens.body1,
      color: Colors.black,
    );
  }

  static TextStyle body2() {
    return _baseTextStyle.copyWith(
      fontWeight: FontWeight.normal,
      fontSize: Dimens.body2,
      color: Colors.black,
    );
  }

  static TextStyle button() {
    return _baseTextStyle.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: Dimens.button,
      color: Colors.black,
    );
  }

  static TextStyle caption() {
    return _baseTextStyle.copyWith(
      fontWeight: FontWeight.normal,
      fontSize: Dimens.caption,
      color: Colors.black,
    );
  }
}
