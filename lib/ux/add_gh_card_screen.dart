import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:unified_checkout_sdk/core_ui/app_page.dart';
import 'package:unified_checkout_sdk/core_ui/dimensions.dart';

import '../core_ui/custom_button.dart';
import '../core_ui/hubtel_colors.dart';
import '../core_ui/input_field.dart';
import '../resources/checkout_drawables.dart';
import '../resources/checkout_strings.dart';

class AddGhCardScreen extends StatelessWidget {
  AddGhCardScreen({super.key});

  final state = AddGhCardScreenState();

  final _cardController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Verification',
      bottomNavigation: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: AnimatedBuilder(
          animation:
              Listenable.merge([state.isButtonEnabled, state.isButtonLoading]),
          builder: (BuildContext context, Widget? child) {
            return CustomButton(
              title: 'Submit'.toUpperCase(),
              isEnabled: state.isButtonEnabled.value,
              buttonAction: () => {state.submit()},
              loading: state.isButtonLoading.value,
              isDisabledBgColor: HubtelColors.lighterGrey,
              disabledTitleColor: HubtelColors.grey,
              style: HubtelButtonStyle.solid,
              // isEnabledBgColor: Theme.of(context).primaryColor,
              isEnabledBgColor: HubtelColors.teal,
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
              Center(child: SvgPicture.asset(CheckoutDrawables.verifySvg)),
              const SizedBox(height: Dimens.paddingDefault),
              Center(
                child: Text(
                  'Verify your Government ID',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: Dimens.paddingDefault),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Text(
                    'A valid government-issued ID card is required to verify your account',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: Dimens.paddingDefault),
              Text('Ghana Card', style: Theme.of(context).textTheme.titleLarge,),
              const SizedBox(height: Dimens.paddingNano),
              ValueListenableBuilder(
                builder: (context, str, child) {
                  return InputField(
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
                  );
                },
                valueListenable: state._cardNumber,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddGhCardScreenState {
  final ValueNotifier<String> _cardNumber = ValueNotifier('');
  final ValueNotifier<bool> _isButtonLoading = ValueNotifier(false);
  final ValueNotifier<bool> _isButtonEnabled = ValueNotifier(true);


  ValueNotifier<String> get cardNumber => _cardNumber;
  ValueNotifier<bool> get isButtonLoading => _isButtonLoading;
  ValueNotifier<bool> get isButtonEnabled => _isButtonEnabled;

  submit() {

  }

  onCardNumberChanged(String value) {
    _cardNumber.value = value;
  }
}
