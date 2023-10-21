import 'package:flutter/material.dart';
import 'package:unified_checkout_sdk/core_ui/text_style.dart';
import 'package:unified_checkout_sdk/platform/models/verification_response.dart';
import 'package:unified_checkout_sdk/resources/checkout_styles.dart';
import '../../core_ui/dimensions.dart';
import '../../resources/checkout_colors.dart';
import '../../resources/checkout_drawables.dart';
import '../../resources/checkout_strings.dart';
import 'info_entry.dart';

class GhanaCard extends StatelessWidget {
  const GhanaCard({super.key, this.verificationResponse});

  final VerificationResponse? verificationResponse;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
          color: CheckoutColors.ghanaCardColor,
          borderRadius: Dimens.borderRadius12),
      child: Stack(
        children: [
          Positioned(
            top: 0.0,
            right: 0.0,
            child: Image.asset(CheckoutDrawables.ghanaArmsCoat),
          ),
          Padding(
            padding: EdgeInsets.all(Dimens.paddingDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  CheckoutStrings.ghanaCardHeading,
                  style: AppTextStyle.body2().copyWith(fontWeight: FontWeight.w800),
                ),
                const Padding(
                    padding: EdgeInsets.only(bottom: Dimens.paddingDefault)),
                InfoCard(
                  label: CheckoutStrings.fullName,
                  value: verificationResponse?.fullName ?? '',
                ),
                const Padding(
                    padding: EdgeInsets.only(bottom: Dimens.paddingDefault)),
                InfoCard(
                  label: CheckoutStrings.personalId,
                  value: verificationResponse?.nationalID ?? '',
                ),
                const Padding(
                    padding: EdgeInsets.only(bottom: Dimens.paddingDefault)),
                Row(
                  children: [
                    InfoCard(
                      label: CheckoutStrings.birthDate,
                      value: verificationResponse?.birthday ?? '',
                    ),
                    const Spacer(flex: 6),
                    InfoCard(
                      label: CheckoutStrings.gender,
                      value: verificationResponse?.gender ?? '',
                    ),
                    const Spacer(flex: 1),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
