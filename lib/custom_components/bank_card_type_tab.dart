
import 'package:flutter/material.dart';
import 'package:unified_checkout_sdk/core_ui/dimensions.dart';
import 'package:unified_checkout_sdk/core_ui/hubtel_colors.dart';
import 'package:unified_checkout_sdk/core_ui/text_style.dart';

class BankCardTypeTab extends StatelessWidget {
  const BankCardTypeTab({
    super.key,
    required this.tabText,
    required this.isSelected,
    required this.onTap,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final String tabText;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: Dimens.paddingDefaultSmall,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: Dimens.paddingDefaultSmall,
          horizontal: Dimens.paddingDefault,
        ),
        decoration: BoxDecoration(
            color: isSelected ? ThemeConfig.themeColor : HubtelColors.neutral,
            borderRadius: BorderRadius.circular(Dimens.paddingDefault)),
        child: Text(
          tabText,
          style: TextStyle(
            color: isSelected ? HubtelColors.neutral.shade100 : HubtelColors.neutral.shade900,
            fontSize: Dimens.caption,
            fontWeight: isSelected ? Dimens.boldFontWeight : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
