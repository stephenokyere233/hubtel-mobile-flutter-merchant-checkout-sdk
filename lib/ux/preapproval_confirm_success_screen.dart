import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unified_checkout_sdk/core_ui/app_image_widget.dart';
import 'package:unified_checkout_sdk/core_ui/app_page.dart';
import 'package:unified_checkout_sdk/core_ui/custom_button.dart';
import 'package:unified_checkout_sdk/core_ui/dimensions.dart';
import 'package:unified_checkout_sdk/core_ui/hubtel_colors.dart';
import 'package:unified_checkout_sdk/core_ui/text_style.dart';
import 'package:unified_checkout_sdk/platform/models/checkout_requirements.dart';
import 'package:unified_checkout_sdk/platform/models/payment_status.dart';
import 'package:unified_checkout_sdk/resources/checkout_drawables.dart';
import 'package:unified_checkout_sdk/utils/currency_formatter.dart';

class PreApprovalConfirmSuccessScreen extends StatelessWidget {

  String walletName;

  double amount;

  Function(PaymentStatus) checkoutCompleted;

  PreApprovalConfirmSuccessScreen(
      {Key? key, required this.walletName, required this.amount, required this.checkoutCompleted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: "Checkout",
      bottomNavigation: Container(
        color: Colors.white,
        padding:  EdgeInsets.all(Dimens.paddingDefault),
        child: CustomButton(
          title:
          'AGREE AND CONTINUE',
          isEnabled: true,
          buttonAction: () {
            Navigator.popUntil(
                context, ModalRoute.withName(CheckoutRequirements.routeName));
                 checkoutCompleted.call(PaymentStatus.paid);
          },
          style: HubtelButtonStyle.solid,
          isEnabledBgColor: ThemeConfig.themeColor,
        ),
      ),
      body: Container(
        color: Color(0XFFDBF7E0),
        padding: EdgeInsets.symmetric(vertical: 55, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(CheckoutDrawables.success),
            SizedBox(height: 8,),
            Text(
              "Your order has been placed",
              textAlign: TextAlign.center,
              style: AppTextStyle.body2(),
            ),
            SizedBox(height: 8,),
            Text(
              "Your ${walletName} will be debited with ${amount.formatMoney()} after your order is confirmed.",
              textAlign: TextAlign.center,
              style: AppTextStyle.body2().copyWith(fontWeight: FontWeight.w700),
            )
          ],
        ),
      ),
    );
  }
}
