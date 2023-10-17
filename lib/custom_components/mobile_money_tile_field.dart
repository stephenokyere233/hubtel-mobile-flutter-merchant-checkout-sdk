import 'package:flutter_remix/flutter_remix.dart';
import 'package:unified_checkout_sdk/core_ui/dimensions.dart';
import 'package:unified_checkout_sdk/core_ui/hubtel_colors.dart';
import 'package:unified_checkout_sdk/core_ui/input_field.dart';
import 'package:unified_checkout_sdk/core_ui/text_style.dart';
import 'package:unified_checkout_sdk/platform/models/momo_provider.dart';
import 'package:unified_checkout_sdk/platform/models/wallet.dart';
import 'package:flutter/material.dart';
import 'package:unified_checkout_sdk/resources/checkout_strings.dart';
import 'package:unified_checkout_sdk/utils/helpers/edge_insets.dart';
import 'package:unified_checkout_sdk/utils/string_extensions.dart';
import 'package:unified_checkout_sdk/ux/add_wallet_screen.dart';

import '../platform/models/wallet_type.dart';

class MobileMoneyTileField extends StatefulWidget {
  const MobileMoneyTileField({
    Key? key,
    required this.fieldController,
    this.wallets,
    this.providers,
    required this.onWalletSelected,
    required this.onProviderSelected,
    required this.hintText,
  }) : super(key: key);

  final TextEditingController fieldController;
  final List<Wallet>? wallets;
  final List<MomoProvider>? providers;
  final String hintText;
  final void Function(Wallet) onWalletSelected;
  final void Function(MomoProvider) onProviderSelected;

  @override
  State<MobileMoneyTileField> createState() => _MobileMoneyTileFieldState();
}

class _MobileMoneyTileFieldState extends State<MobileMoneyTileField> {
  bool expandOptions = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InputField(
          hasFill: true,
          hintText: widget.hintText,
          controller: widget.fieldController,
          readOnly: true,
          suffixWidget: Padding(
            padding: const EdgeInsets.only(right: Dimens.paddingDefaultSmall),
            child: Icon(
              expandOptions == true
                  ? FlutterRemix.arrow_up_s_line
                  : FlutterRemix.arrow_down_s_line,
              color: HubtelColors.neutral.shade900,
            ),
          ),
          onTap: () {
            setState(() {
              expandOptions = !expandOptions;
            });
          },
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(Dimens.inputBorderRadius),
          ),
          // contentPadding: symmetricPad(
          //   horizontal: AppDimens.paddingDefault,
          // ),
        ),
        Visibility(
          visible: expandOptions,
          child: Card(
            elevation: 7,
            shadowColor: HubtelColors.neutral.shade300,
            margin: onlySidePad(
              top: Dimens.paddingMicro,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                Dimens.defaultBorderRadius,
              ),
            ),
            child: Container(
              width: double.maxFinite,
              child: Column(
                children: widget.wallets != null
                    ? [
                        ...widget.wallets!.map((e) {
                          if (e.type?.toLowerCase() ==
                                  WalletType.Card.optionValue.toLowerCase() ||
                              e.type?.toLowerCase() ==
                                  WalletType.Hubtel.optionValue.toLowerCase()) {
                            return const SizedBox();
                          }
                          return ListTile(
                            onTap: () {
                              setState(() {
                                widget.fieldController.text = e.accountNo ?? '';
                              });
                              expandOptions = false;
                              widget.onWalletSelected(e);
                            },
                            title: Text(
                              e.accountNo ?? '',
                              style: AppTextStyle.body2(),
                            ),
                            subtitle: Text(
                              (e.provider ?? '').capitalize(),
                              style: AppTextStyle.body2().copyWith(
                                  color: HubtelColors.neutral.shade600),
                            ),
                          );
                        }),
                        ListTile(
                          onTap: () {
                            setState(() {
                              expandOptions = false;
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddWalletScreen(),
                              ),
                            );
                          },
                          leading: const Icon(
                            Icons.add_circle_outline_rounded,
                            color: HubtelColors.teal,
                            size: Dimens.defaultIconNormal,
                          ),
                          title: Text(
                            CheckoutStrings.addMobileMoneyWallet,
                            style: AppTextStyle.body2().copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          minLeadingWidth: Dimens.paddingNano,
                        )
                      ]
                    : widget.providers != null
                        ? widget.providers!
                            .map(
                              (e) => ListTile(
                                onTap: () {
                                  setState(() {
                                    widget.fieldController.text = e.name ?? "";
                                  });
                                  expandOptions = false;
                                  widget.onProviderSelected(e);
                                },
                                title: Text(
                                  e.name ?? "",
                                  style: AppTextStyle.body2(),
                                ),
                                dense: true,
                                minVerticalPadding: 0,
                              ),
                            )
                            .toList()
                        : [],
              ),
            ),
          ),
        )
      ],
    );
  }
}
