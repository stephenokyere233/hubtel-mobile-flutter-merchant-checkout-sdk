
import 'package:flutter/material.dart';
import 'package:unified_checkout_sdk/core_ui/hubtel_colors.dart';
import 'package:unified_checkout_sdk/core_ui/text_style.dart';
import 'package:unified_checkout_sdk/utils/currency_formatter.dart';

class PaymentCardHorizontalInfo extends StatelessWidget {
  const PaymentCardHorizontalInfo({
    Key? key,
    required this.detail,
    required this.value,
  }) : super(key: key);

  final String detail;
  final double? value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          detail,
          style: AppTextStyle.body2().copyWith(
            color: HubtelColors.neutral.shade900,
          ),
        ),
        Text(
          value?.formatMoney() ?? '0.00',
          style: AppTextStyle.body2().copyWith(
            color: HubtelColors.neutral.shade900,
          ),
        )
      ],
    );
  }
}
