import 'package:flutter/material.dart';
import 'package:unified_checkout_sdk/core_ui/app_page.dart';
import 'package:unified_checkout_sdk/platform/models/verification_response.dart';

import '../core_ui/custom_button.dart';
import '../core_ui/dimensions.dart';
import '../core_ui/hubtel_colors.dart';
import '../core_ui/text_style.dart';
import '../resources/checkout_strings.dart';
import 'components/ghana_card.dart';
import 'components/verification_card.dart';

class GhanaCardVerificationScreen extends StatelessWidget {
  const GhanaCardVerificationScreen({super.key, this.verificationResponse});

  final VerificationResponse? verificationResponse;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: CheckoutStrings.titleVerification,
      bottomNavigation: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(Dimens.paddingDefault),
        child: CustomButton(
          title: 'Submit'.toUpperCase(),
          isEnabled: true,
          buttonAction: () => {},
          isDisabledBgColor: HubtelColors.lighterGrey,
          disabledTitleColor: HubtelColors.grey,
          style: HubtelButtonStyle.solid,
          isEnabledBgColor: ThemeConfig.themeColor,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            const VerificationCard(),
            GhanaCard(verificationResponse: verificationResponse),
          ],
        ),
      ),
    );
  }
}
