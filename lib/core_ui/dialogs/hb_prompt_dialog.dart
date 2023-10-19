

import 'package:flutter/material.dart';
import 'package:unified_checkout_sdk/core_ui/buttons/hb_button_large.dart';
import 'package:unified_checkout_sdk/core_ui/dialogs/hb_rounded_dialog.dart';
import 'package:unified_checkout_sdk/core_ui/dimensions.dart';
import 'package:unified_checkout_sdk/core_ui/text_style.dart';
class HBPromptDialog extends StatelessWidget {
  String title;
  String subtitle;
  String buttonTitle;
  VoidCallback? buttonAction;

  HBPromptDialog({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.buttonTitle,
    required this.buttonAction
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  HBRoundedDialog(
      padding: const EdgeInsets.all(Dimens.paddingDefault),
      borderRadius: Dimens.defaultBorderRadius,
      widget: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: AppTextStyle.headline3(),),
          const SizedBox(height: 8,),
          Align(
              alignment: Alignment.center,
              child: Text(subtitle)
          ),
          const SizedBox(height: 8,),
          HBPlainTextButtonLarge.createTealButton(
            title: buttonTitle,
            buttonAction: buttonAction,
            padding: 0,
          )
        ],
      ),
    );
  }
}