
import 'package:flutter/cupertino.dart';
import 'package:unified_checkout_sdk/core_ui/dialogs/loading_dialog.dart';

extension WidgetExtensions on StatefulWidget {
  showLoadingDialog({required BuildContext context, required String text}) {
    loadingDialog(context, loadingText: text);
  }
}