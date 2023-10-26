import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:unified_checkout_sdk/core_ui/app_page.dart';
import 'package:unified_checkout_sdk/core_ui/text_style.dart';
import 'package:unified_checkout_sdk/core_ui/ui_extensions/widget_extensions.dart';
import 'package:unified_checkout_sdk/extensions/widget_extensions.dart';
import 'package:unified_checkout_sdk/network_manager/extensions/uistate.dart';
import 'package:unified_checkout_sdk/platform/models/checkout_payment_status_response.dart';
import 'package:unified_checkout_sdk/platform/models/mobile_money_request.dart';
import 'package:unified_checkout_sdk/platform/models/momo_response.dart';
import 'package:unified_checkout_sdk/platform/models/payment_status.dart';
import 'package:unified_checkout_sdk/ux/check_status_screen.dart';
import 'package:unified_checkout_sdk/ux/viewModel/checkout_view_model.dart';

import '../core_ui/custom_button.dart';
import '../core_ui/dimensions.dart';
import '../core_ui/hubtel_colors.dart';
import '../core_ui/input_field.dart';
import '../resources/checkout_strings.dart';

class NewMandateIdScreen extends StatefulWidget {
  NewMandateIdScreen({required this.momoRequest, super.key});

  MobileMoneyPaymentRequest momoRequest;

  @override
  State<NewMandateIdScreen> createState() => _NewMandateIdScreenState();
}

class _NewMandateIdScreenState extends State<NewMandateIdScreen> {
  final state = NewMandateIdScreenState();

  final _mandateIdController = TextEditingController();

  final viewModel = CheckoutViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppPage(
        title: 'Mandate ID',
        bottomNavigation: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: ValueListenableBuilder(
            valueListenable: state,
            builder: (context, value, child) {
              return CustomButton(
                title: 'Continue'.toUpperCase(),
                isEnabled: state.validated,
                buttonAction: () => {_makeCheckoutPayment()},
                isDisabledBgColor: HubtelColors.lighterGrey,
                disabledTitleColor: HubtelColors.grey,
                style: HubtelButtonStyle.solid,
                isEnabledBgColor: ThemeConfig.themeColor,
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Dimens.paddingDefault),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimens.paddingDefault),
                  Text(
                    'Mandate ID',
                    style: AppTextStyle.body1(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Dimens.paddingDefault),
                  InputField(
                    controller: _mandateIdController,
                    hintText: CheckoutStrings.mandateIdHint,
                    onChanged: (value) {
                      state.onIdChanged(value);
                      // log('$runtimeType ${state.mobileNumber.value}');
                    },
                    inputType: TextInputType.number,
                    // autofocus: true,
                    hasFill: true,
                    focusBorderColor: Colors.transparent,
                  ),
                  const SizedBox(height: Dimens.paddingDefault),
                  Text(
                    CheckoutStrings.gMoneyInstructionsHeading,
                    style: AppTextStyle.body2()
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: Dimens.paddingDefault),
                  Text(
                    CheckoutStrings.gMoneySteps,
                    style: AppTextStyle.body2(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _makeCheckoutPayment() async {
    widget.showLoadingDialog(context: context, text: "Please Wait");

    widget.momoRequest.mandateId = state.value.id;

    viewModel.prefManager.mandateId = state.value.id;

    final response = await viewModel.payWithMomo(req: widget.momoRequest);

    if (!mounted) return;

    Navigator.pop(context);

    if (response.state == UiState.success) {
      final data = response.data;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckStatusScreen(
              checkoutResponse: data ?? MomoResponse(),
              checkoutCompleted: (status) => {}),
        ),
      );
    } else {
      widget.showErrorDialog(context: context, message: response.message);
    }
  }
}

class NewMandateIdScreenState extends ValueNotifier<MandateScreenUiModel> {
  NewMandateIdScreenState() : super(MandateScreenUiModel());

  // CheckoutViewModel checkoutViewModel;

  bool get validated => value.isButtonEnabled;

  onIdChanged(String id) {
    value.id = id;
    value.isButtonEnabled = value.id.length >= 5;
    log(value.id, name: '$runtimeType');
    notifyListeners();
  }

  submit() {}
}

class MandateScreenUiModel {
  bool _isButtonEnabled = false;
  String _id = '';

  bool get isButtonEnabled => _isButtonEnabled;

  set isButtonEnabled(bool value) {
    _isButtonEnabled = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }
}
