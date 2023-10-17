import 'package:flutter/material.dart';
import '../../core_ui/dimensions.dart';
import '../../resources/checkout_colors.dart';
import '../../resources/checkout_styles.dart';

class InfoCard extends StatelessWidget {
  const InfoCard(
      {super.key,
      required this.label,
      this.labelColor = CheckoutColors.cardLabelColor,
      required this.value,
      this.valueStyle});

  final String label;
  final Color labelColor;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Styles.cardLabelStyle.copyWith(color: labelColor),
        ),
        const Padding(padding: EdgeInsets.only(bottom: Dimens.paddingNano)),
        Text(
          value,
          style:
              Styles.cardInfoStyle.copyWith(fontWeight: valueStyle?.fontWeight),
        ),
      ],
    );
  }
}
