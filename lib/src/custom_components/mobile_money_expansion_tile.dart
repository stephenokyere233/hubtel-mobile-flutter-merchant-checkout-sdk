import 'package:flutter/material.dart';
import 'package:hubtel_merchant_checkout_sdk/src/utils/custom_expansion_widget.dart'
    as customExpansion;
import 'package:hubtel_merchant_checkout_sdk/src/ux/view_model/checkout_view_model.dart';

import '../core_ui/core_ui.dart';
import '../platform/models/models.dart';
import '../resources/checkout_drawables.dart';
import '../resources/checkout_strings.dart';
import 'custom_components.dart';
import 'mobile_money_tile_field.dart';

class MobileMoneyExpansionTile extends StatefulWidget {
  static bool fetchFees = true;

  MobileMoneyExpansionTile(
      {super.key,
      required this.wallets,
      required this.providers,
      required this.mobileNumberController,
      required this.providerController,
      required this.onWalletSelected,
      required this.onProviderSelected,
      required this.controller,
      required this.onExpansionChanged,
      required this.isSelected,
      required this.selectedProviderMessage,
      this.walletAdditionComplete,
      this.mobileNumberFocusNode,
      required this.disableUserNumberInputInteraction});

  final List<Wallet> wallets;
  final List<MomoProvider> providers;
  final TextEditingController mobileNumberController;
  final TextEditingController providerController;
  final void Function(Wallet) onWalletSelected;
  final void Function(MomoProvider) onProviderSelected;
  final customExpansion.ExpansionTileController controller;
  final void Function(bool)? onExpansionChanged;
  final bool isSelected;
  final Widget selectedProviderMessage;
  VoidCallback? walletAdditionComplete;
  final FocusNode? mobileNumberFocusNode;
  bool disableUserNumberInputInteraction;

  @override
  State<MobileMoneyExpansionTile> createState() =>
      _MobileMoneyExpansionTileState();
}

class _MobileMoneyExpansionTileState extends State<MobileMoneyExpansionTile> {
  bool expandOptions = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.isSelected) const SizedBox(height: Dimens.paddingDefault),

        //
        customExpansion.ExpansionTile(
          // tilePadding: EdgeInsets.symmetric(vertical: -10, horizontal: 16)
          controller: widget.controller,
          headerBackgroundColor: widget.isSelected
              // ? HubtelColors.teal.shade100
              ? ThemeConfig.themeColor.withOpacity(0.3)
              : Colors.transparent,
          onExpansionChanged: (expanded) {
            // Use Future.microtask to avoid interrupting the current build cycle
            // which can cause keyboard dismissal
            if (widget.onExpansionChanged != null) {
              Future.microtask(() => widget.onExpansionChanged!(expanded));
            }
          },
          title: Text(
            CheckoutStrings.mobileMoney,
            style: AppTextStyle.body2(),
          ),
          expandedAlignment: Alignment.topLeft,
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: Dimens.paddingDefault,
            vertical: Dimens.paddingDefault,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Visibility(
                visible: CheckoutViewModel.channelFetch?.channels
                        ?.contains("mtn-gh") ??
                    false,
                child: AppImageWidget.local(
                  image: const AssetImage(CheckoutDrawables.mtnMomoLogo),
                  width: Dimens.iconMedium,
                  height: Dimens.iconSmall,
                  boxFit: BoxFit.contain,
                  borderRadius: 0,
                ),
              ),
              const SizedBox(width: Dimens.paddingDefaultSmall),
              Visibility(
                visible: CheckoutViewModel.channelFetch?.channels
                        ?.contains("vodafone-gh") ??
                    false,
                child: AppImageWidget.local(
                  image: const AssetImage(CheckoutDrawables.vodafoneCashLogo),
                  width: Dimens.iconSmall,
                  height: Dimens.iconSmall,
                  boxFit: BoxFit.contain,
                  borderRadius: 0,
                ),
              ),
              const SizedBox(width: Dimens.paddingDefaultSmall),
              Visibility(
                visible: CheckoutViewModel.channelFetch?.channels
                        ?.contains("tigo-gh") ??
                    false,
                child: AppImageWidget.local(
                  image: const AssetImage(CheckoutDrawables.airtelTigoLogo),
                  width: Dimens.iconSmall,
                  height: Dimens.iconSmall,
                  boxFit: BoxFit.contain,
                  borderRadius: 0,
                ),
              ),
            ],
          ),
          leading: CustomRadioIndicator(
            isSelected: widget.isSelected,
          ),
          leadingWidth: Dimens.iconMedium,
          titleAlignment: ListTileTitleAlignment.center,
          children: [
            MobileMoneyTileField(
              fieldController: widget.mobileNumberController,
              onWalletSelected: widget.onWalletSelected,
              onProviderSelected: widget.onProviderSelected,
              wallets: widget.wallets,
              hintText: CheckoutStrings.mobileNumber,
              isReadOnly: widget.disableUserNumberInputInteraction,
              focusNode: widget.mobileNumberFocusNode,
              onWalletUpdateComplete: () {
                widget.walletAdditionComplete?.call();
              },
            ),
            const SizedBox(height: Dimens.paddingDefault),
            MobileMoneyTileField(
              fieldController: widget.providerController,
              onWalletSelected: widget.onWalletSelected,
              onProviderSelected: widget.onProviderSelected,
              providers: widget.providers,
              hintText: CheckoutStrings.mobileNetwork,
            ),
            const SizedBox(height: Dimens.paddingDefault),
            widget.selectedProviderMessage,
            // const SizedBox(height: AppDimens.paddingDefault),
          ],
        ),
      ],
    );
  }
}
