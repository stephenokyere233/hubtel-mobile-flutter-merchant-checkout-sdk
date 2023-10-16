
import 'package:flutter/material.dart';
import 'package:unified_checkout_sdk/core_ui/loading_indicator.dart';
import 'package:unified_checkout_sdk/core_ui/text_style.dart';



loadingDialog(BuildContext context, {String? loadingText}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(7.0)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(
            height: 40,
            width: 40,
            child: LoadingIndicator(),
          ),
          const SizedBox(height: 15),
          Text(
            loadingText ?? 'Loading...',
            style: AppTextStyle.body2(),
          ),
        ],
      ),
    ),
  );
}