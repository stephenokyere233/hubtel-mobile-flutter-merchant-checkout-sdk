import 'package:flutter/material.dart';
import 'package:unified_checkout_sdk/core_ui/dimensions.dart';

import '../../resources/checkout_colors.dart';
import '../../resources/checkout_styles.dart';

class HAppBar extends AppBar {
  HAppBar({
    super.key,
    required String title,
    TextStyle? style  = Styles.appBarTextStyle,
    Color? backgroundColor = CheckoutColors.defaultWhiteColor,
    double? toolbarHeight = Dimens.toolBarHeight,
    Widget? leading,
  }) : super(
    leading: leading,
    toolbarHeight: toolbarHeight,
    backgroundColor: backgroundColor,
    title: Text(
      title,
      style: style,
    ),
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(
        height: 1,
      ),
    ),
  );
}