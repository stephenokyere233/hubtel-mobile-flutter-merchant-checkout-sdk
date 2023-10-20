import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unified_checkout_sdk/core_ui/app_page.dart';
import 'package:unified_checkout_sdk/core_ui/dimensions.dart';
import 'package:unified_checkout_sdk/core_ui/hubtel_colors.dart';
import 'package:unified_checkout_sdk/core_ui/text_style.dart';
import 'package:unified_checkout_sdk/resources/checkout_strings.dart';

import '../core_ui/custom_button.dart';
import '../resources/checkout_drawables.dart';

class BankPayStatusScreen extends StatelessWidget {
  const BankPayStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Confirm Process',
      hideBackNavigation: true,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            CheckoutStrings.cancel,
            style: AppTextStyle.body2().copyWith(
              color: HubtelColors.crimson,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
      bottomNavigation: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: CustomButton(
          title: CheckoutStrings.okay.toUpperCase(),
          isEnabled: true,
          buttonAction: () => onOkayButtonClicked(),
          isDisabledBgColor: HubtelColors.lighterGrey,
          disabledTitleColor: HubtelColors.grey,
          style: HubtelButtonStyle.solid,
          isEnabledBgColor: ThemeConfig.themeColor,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Dimens.paddingDefault),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(CheckoutDrawables.transactionSuccessful),
              const SizedBox(height: Dimens.paddingSmall),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: CheckoutStrings.payAtBankBranch,
                  style: AppTextStyle.body2(),
                  children: <TextSpan>[
                    TextSpan(
                      text: CheckoutStrings.ghanaGov,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ThemeConfig.themeColor,
                      ),
                    ),
                    TextSpan(
                      text: CheckoutStrings.paymentPlatform,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimens.paddingSmall),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: CheckoutStrings.bankPayStatusSteps1,
                  style: AppTextStyle.body2(),
                  children: <TextSpan>[
                    TextSpan(text: CheckoutStrings.bankPayStatusSteps2),
                    TextSpan(text: CheckoutStrings.bankPayStatusSteps3),
                    TextSpan(
                      text: CheckoutStrings.bankPayShortCode,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  onOkayButtonClicked() async {
    // TODO: implement okay clicked in bank pay status screen
  }
}
