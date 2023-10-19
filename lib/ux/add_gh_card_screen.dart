import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:unified_checkout_sdk/core_ui/app_page.dart';
import 'package:unified_checkout_sdk/core_ui/dimensions.dart';
import 'package:unified_checkout_sdk/ux/viewModel/checkout_view_model.dart';

import '../core_ui/custom_button.dart';
import '../core_ui/hubtel_colors.dart';
import '../core_ui/input_field.dart';
import '../resources/checkout_drawables.dart';
import '../resources/checkout_strings.dart';

class AddGhCardScreen extends StatelessWidget {
  AddGhCardScreen({super.key});

  final _cardController = TextEditingController();
  final viewModel = CheckoutViewModel();

  @override
  Widget build(BuildContext context) {
    final state = AddGhCardScreenState(viewModel: viewModel);
    return AppPage(
      title: 'Verification',
      bottomNavigation: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: ValueListenableBuilder(
          builder: (context, uiModel, child) => CustomButton(
            title: 'Submit'.toUpperCase(),
            isEnabled: state.value.isButtonEnabled,
            buttonAction: () => {state.submit()},
            loading: state.value.isButtonLoading,
            isDisabledBgColor: HubtelColors.lighterGrey,
            disabledTitleColor: HubtelColors.grey,
            style: HubtelButtonStyle.solid,
            // isEnabledBgColor: Theme.of(context).primaryColor,
            isEnabledBgColor: HubtelColors.teal,
          ),
          valueListenable: state.ghCardState,
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
              Center(child: SvgPicture.asset(CheckoutDrawables.verifySvg)),
              const SizedBox(height: Dimens.paddingDefault),
              Center(
                child: Text(
                  'Verify your Government ID',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: Dimens.paddingDefault),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Text(
                    'A valid government-issued ID card is required to verify your account',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: Dimens.paddingDefault),
              Text(
                'Ghana Card',
                style: Theme.of(context).textTheme.titleLarge,
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
}

class AddGhCardScreenState extends ValueNotifier<AddGhCardUiModel> {
  CheckoutViewModel viewModel;
  AddGhCardScreenState({required this.viewModel}) : super(AddGhCardUiModel());

  onCardNumberChanged(String number) {
    value.cardNumber = number;
    value.isButtonEnabled = value.cardNumber.length >= 15;
    log(value.cardNumber, name: '$runtimeType');
    notifyListeners();
  }

  AddGhCardScreenState get ghCardState => this;

  submit() async {
    viewModel.fetchWallets().then((value) {
      log(value.data.toString(), name: '$runtimeType');
    }).onError((error, stackTrace) {
      log('$error', name: '$runtimeType', error: stackTrace);
    });
  }
}

class AddGhCardUiModel {
  String _cardNumber = '';
  bool _isButtonLoading = false;
  bool _isButtonEnabled = false;

  String get cardNumber => _cardNumber;

  set cardNumber(String value) {
    _cardNumber = value;
  }

  bool get isButtonLoading => _isButtonLoading;

  set isButtonLoading(bool value) {
    _isButtonLoading = value;
  }

  bool get isButtonEnabled => _isButtonEnabled;

  set isButtonEnabled(bool value) {
    _isButtonEnabled = value;
  }
}
