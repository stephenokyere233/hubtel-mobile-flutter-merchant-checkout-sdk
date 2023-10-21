import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:unified_checkout_sdk/core_ui/app_page.dart';
import 'package:unified_checkout_sdk/core_ui/dimensions.dart';
import 'package:unified_checkout_sdk/core_ui/text_style.dart';
import 'package:unified_checkout_sdk/core_ui/ui_extensions/widget_extensions.dart';
import 'package:unified_checkout_sdk/extensions/widget_extensions.dart';
import 'package:unified_checkout_sdk/network_manager/extensions/uistate.dart';
import 'package:unified_checkout_sdk/platform/models/id_verification_request_body.dart';
import 'package:unified_checkout_sdk/ux/gh_card_verification_screen.dart';
import 'package:unified_checkout_sdk/ux/viewModel/checkout_view_model.dart';

import '../core_ui/custom_button.dart';
import '../core_ui/hubtel_colors.dart';
import '../core_ui/input_field.dart';
import '../resources/checkout_drawables.dart';
import '../resources/checkout_strings.dart';

class AddGhCardScreen extends StatefulWidget {

  String mobileNumber;

  AddGhCardScreen({
    super.key,
    required this.mobileNumber
  });

  @override
  State<AddGhCardScreen> createState() => _AddGhCardScreenState();
}

class _AddGhCardScreenState extends State<AddGhCardScreen> {
  final _cardController = TextEditingController();

  late final state = _AddGhCardState();

  final viewModel = CheckoutViewModel();

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Verification',
      bottomNavigation: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(Dimens.paddingDefault),
        child: ValueListenableBuilder(
          builder: (context, uiModel, child) => CustomButton(
            title: 'Submit'.toUpperCase(),
            isEnabled: state.value.isButtonEnabled,
            buttonAction: () => _performVerificationDetailsCheck(context),
            loading: state.value.isButtonLoading,
            isDisabledBgColor: HubtelColors.lighterGrey,
            disabledTitleColor: HubtelColors.grey,
            style: HubtelButtonStyle.solid,
            isEnabledBgColor: ThemeConfig.themeColor,
          ),
          valueListenable: state.ghCardState,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Dimens.paddingDefault),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Dimens.paddingDefault),
              Center(child: SvgPicture.asset(CheckoutDrawables.verifySvg)),
              const SizedBox(height: Dimens.paddingDefault),
              Center(
                child: Text(
                  'Verify your Government ID',
                  // style: Theme.of(context)
                  //     .textTheme
                  //     .bodyLarge
                  //     ?.copyWith(fontWeight: FontWeight.bold),
                  style: AppTextStyle.body2().copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: Dimens.paddingDefault),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Text(
                    'A valid government-issued ID card is required to verify your account',
                    // style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                    style: AppTextStyle.body2(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: Dimens.paddingDefault),
              Text(
                'Ghana Card',
                style: AppTextStyle.body2(),
              ),
              const SizedBox(height: Dimens.paddingNano),
              InputField(
                controller: _cardController,
                hintText: CheckoutStrings.ghanaCardNumberHint,
                onChanged: (value) {
                  state.onCardNumberChanged(value);
                  // log('$runtimeType ${state.mobileNumber.value}');
                },
                inputType: TextInputType.number,
                // autofocus: true,
                hasFill: true,
                focusBorderColor: Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _performVerificationDetailsCheck(BuildContext) async {
    final verificationReqParams =
        IDVerificationBody.create(widget.mobileNumber ?? "", state.value.cardNumber);

    widget.showLoadingDialog(
        context: context, text: CheckoutStrings.pleaseWait);

    final result =
        await viewModel.intakeIdDetails(params: verificationReqParams);

    if (!mounted) return;

    Navigator.pop(context);

    if (result.state == UiState.success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GhanaCardVerificationScreen(
            verificationResponse: result.data,
          ),
        ),
      );
    } else {
      widget.showErrorDialog(context: context, message: result.message);
    }
  }
}

class _AddGhCardState extends ValueNotifier<_AddGhCardUiModel> {
  _AddGhCardState() : super(_AddGhCardUiModel());

  onCardNumberChanged(String number) {
    value.cardNumber = number;
    value.isButtonEnabled = value.cardNumber.length >= 15;
    log(value.cardNumber, name: '$runtimeType');
    notifyListeners();
  }

  _AddGhCardState get ghCardState => this;
}

class _AddGhCardUiModel {
  String cardNumber = '';
  bool isButtonLoading = false;
  bool isButtonEnabled = false;
}
