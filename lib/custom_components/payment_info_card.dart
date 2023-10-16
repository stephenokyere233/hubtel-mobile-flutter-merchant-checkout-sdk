

import 'package:flutter/material.dart';
import 'package:unified_checkout_sdk/core_ui/dimensions.dart';
import 'package:unified_checkout_sdk/core_ui/hubtel_colors.dart';
import 'package:unified_checkout_sdk/core_ui/text_style.dart';
import 'package:unified_checkout_sdk/custom_components/payment_info_horizontal.dart';
import 'package:unified_checkout_sdk/custom_components/zigzag_clipper.dart';
import 'package:unified_checkout_sdk/platform/models/business_info.dart';
import 'package:unified_checkout_sdk/platform/models/purchase_item.dart';
import 'package:unified_checkout_sdk/resources/checkout_strings.dart';
import 'package:unified_checkout_sdk/utils/currency_formatter.dart';

import '../core_ui/app_image_widget.dart';

// import 'app_image_asset.dart';

class PaymentInfoCard extends StatelessWidget {

  PurchaseInfo checkoutPurchase;
  BusinessInfo businessInfo;
  double? checkoutFees;
  double? totalAmountPayble;


   PaymentInfoCard({
    Key? key,
    required this.checkoutPurchase,
     required this.businessInfo,
    this.checkoutFees,
     this.totalAmountPayble
  }): super(key:key);

  // final CheckoutPurchase checkoutPurchase;
  // final List<CheckoutFee> checkoutFees;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.symmetric(
        horizontal: Dimens.paddingLarge,
        // vertical: AppDimens.paddingDefaultNormal,
      ),
      // decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RotatedBox(
              quarterTurns: 2,
              child: ClipPath(
                clipper: ZigzagClipper(
                  lineCount: 34,
                  lineHeight: 5,
                ),
                child: Container(
                  height: 30,
                  width: double.maxFinite,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: HubtelColors.neutral.shade100,
                    border: Border.symmetric(
                      vertical: BorderSide(
                        color: HubtelColors.neutral.shade400,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            //
            Container(
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(
                horizontal: Dimens.paddingDefault,
              ),
              decoration: BoxDecoration(
                color: HubtelColors.neutral.shade100,
                border: Border(
                  left: BorderSide(color: HubtelColors.neutral.shade400),
                  right: BorderSide(color: HubtelColors.neutral.shade400),
                  bottom: BorderSide(color: HubtelColors.neutral.shade400),
                ),
              ),
              child: Column(
                children: [
                  //
                  const SizedBox(
                    height: Dimens.paddingNano,
                  ),

                  // school info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //logo
                      AppImageWidget(
                        imageUrl: businessInfo?.businessImageUrl ?? "",
                        errorImage: AssetImage(businessInfo?.businessImageUrl ?? ""),
                        placeHolder: AssetImage(
                        businessInfo?.businessImageUrl ?? "",
                        ),
                        borderRadius: Dimens.normalCircleAvatarRadius,
                        height: 48,
                        width: 48,
                      ),

                      //
                      const SizedBox(
                        width: Dimens.normalSpacing,
                      ),

                      //name
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            businessInfo.businessName,
                            style: AppTextStyle.body2().copyWith(
                              color: HubtelColors.neutral.shade900,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          //
                          const SizedBox(
                            height: Dimens.paddingMicro,
                          ),

                          // Text(
                          //   checkoutPurchase.description,
                          //   style: AppTextStyle.caption().copyWith(
                          //     color: HubtelColors.yellow.shade700,
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),

                  //
                  const SizedBox(
                    height: Dimens.paddingNano,
                  ),

                  //
                  Divider(
                    color: HubtelColors.neutral.shade400,
                    thickness: 1,
                    // height: 0,
                  ),

                  //
                  const SizedBox(
                    height: Dimens.paddingDefault,
                  ),

                  //
                  PaymentCardHorizontalInfo(
                    detail: CheckoutStrings.amount,
                    value: checkoutPurchase.amount
                    // checkoutPurchase.instantServicePurchase?.amount ?? 0.0,
                  ),

                  //
                  const SizedBox(height: Dimens.paddingNano),

                  PaymentCardHorizontalInfo(
                    detail: CheckoutStrings.fees,
                    value: checkoutFees

                  ),
                  // const SizedBox(height: Dimens.paddingNano),

                  // PaymentCardHorizontalInfo(
                  //   detail: CheckoutStrings.elevy,
                  //   value: 0.00,
                  // ),

                  const SizedBox(height: Dimens.paddingDefault),
                ],
              ),
            ),

            ClipPath(
              clipper: ZigzagClipper(
                lineCount: 34,
                lineHeight: 10,
              ),
              child: Container(
                width: double.maxFinite,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: HubtelColors.yellow.shade200,
                  border: Border(
                    left: BorderSide(color: HubtelColors.neutral.shade400),
                    right: BorderSide(color: HubtelColors.neutral.shade400),
                    top: BorderSide(color: HubtelColors.neutral.shade400),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: Dimens.paddingDefault),
                    //
                    Text(
                      CheckoutStrings.youWillBeCharged,
                      style: AppTextStyle.caption().copyWith(
                        color: HubtelColors.yellow.shade800,
                      ),
                    ),

                    const SizedBox(height: Dimens.paddingNano),

                    Text(
                      (totalAmountPayble ?? checkoutPurchase.amount).formatMoney(),
                      style: AppTextStyle.headline2().copyWith(
                        color: HubtelColors.neutral.shade900,
                      ),
                    ),

                    const SizedBox(height: Dimens.mediumSpacing),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
