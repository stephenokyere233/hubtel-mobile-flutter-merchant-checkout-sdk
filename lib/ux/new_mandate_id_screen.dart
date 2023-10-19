import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:unified_checkout_sdk/core_ui/app_page.dart';
import 'package:unified_checkout_sdk/ux/viewModel/checkout_view_model.dart';

import '../core_ui/custom_button.dart';
import '../core_ui/dimensions.dart';
import '../core_ui/hubtel_colors.dart';
import '../core_ui/input_field.dart';
import '../resources/checkout_strings.dart';

class NewMandateIdScreen extends StatelessWidget {
  NewMandateIdScreen({super.key});

  final state = NewMandateIdScreenState(checkoutViewModel: CheckoutViewModel());
  final _mandateIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppPage(
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
              buttonAction: () => {state.submit()},
              isDisabledBgColor: HubtelColors.lighterGrey,
              disabledTitleColor: HubtelColors.grey,
              style: HubtelButtonStyle.solid,
              isEnabledBgColor: Theme.of(context).primaryColor,
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Dimens.paddingNano),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Dimens.paddingDefault),
              Text(
                'Mandate ID',
                style: Theme.of(context).textTheme.bodyMedium,
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
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: Dimens.paddingDefault),
              Text(
                CheckoutStrings.gMoneySteps,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewMandateIdScreenState extends ValueNotifier<MandateScreenUiModel> {
  NewMandateIdScreenState({required this.checkoutViewModel})
      : super(MandateScreenUiModel());

  CheckoutViewModel checkoutViewModel;

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
