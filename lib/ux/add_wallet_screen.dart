import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:unified_checkout_sdk/core_ui/app_page.dart';
import 'package:unified_checkout_sdk/core_ui/dimensions.dart';
import 'package:unified_checkout_sdk/core_ui/input_field.dart';
import 'package:unified_checkout_sdk/resources/checkout_strings.dart';
import 'package:unified_checkout_sdk/utils/string_extensions.dart';
import 'package:unified_checkout_sdk/ux/viewModel/checkout_view_model.dart';

import '../core_ui/custom_button.dart';
import '../core_ui/hubtel_colors.dart';
import '../custom_components/circle_image.dart';
import '../resources/checkout_drawables.dart';

class AddWalletScreen extends StatelessWidget {
  AddWalletScreen({super.key});

  final _mobileNumberController = TextEditingController();
  final checkoutViewModel = CheckoutViewModel();

  @override
  Widget build(BuildContext context) {
    final AddWalletScreenState state =
    AddWalletScreenState(checkoutViewModel: checkoutViewModel);
    return AppPage(
      title: CheckoutStrings.addWalletScreenTitle,
      elevation: 0.1,
      bottomNavigation: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: AnimatedBuilder(
          animation:
          Listenable.merge([state.isButtonEnabled, state.isButtonLoading]),
          builder: (BuildContext context, Widget? child) {
            return CustomButton(
              title: 'CONTINUE'.toUpperCase(),
              isEnabled: state.isButtonEnabled.value,
              buttonAction: () => {state.addWallet()},
              loading: state.isButtonLoading.value,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: Dimens.paddingLarge,
            ),
            Text(
              CheckoutStrings.mobileMoneyNumber,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.black,
              ),
            ),
            const SizedBox(
              height: Dimens.paddingSmall,
            ),
            ValueListenableBuilder(
              builder: (context, str, child) {
                return InputField(
                  controller: _mobileNumberController,
                  hintText: CheckoutStrings.addNumberHint,
                  onChanged: (value) {
                    state.onNumberChanged(value);
                    // log('$runtimeType ${state.mobileNumber.value}');
                  },
                  inputType: TextInputType.number,
                  // autofocus: true,
                  hasFill: true,
                  focusBorderColor: Colors.transparent,
                );
              },
              valueListenable: state._mobileNumber,
            ),
            const SizedBox(
              height: Dimens.paddingDefault,
            ),
            Text(
              CheckoutStrings.selectNetwork,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.black,
              ),
            ),
            const SizedBox(
              height: Dimens.paddingSmall,
            ),
            SizedBox(
              height: 140.0,
              child: ValueListenableBuilder(
                builder: (context, boolean, child) {
                  return ListView.separated(
                    shrinkWrap: false,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          CircleImage(
                            imageProvider:
                            AssetImage(state.providers[index].$2),
                            borderColor: state.selectedIndex.value == index
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            onTap: () {
                              state.selectedIndex.value = index;
                              state.onProviderSelected(index);
                              state.mobileNumber.value =
                                  _mobileNumberController.value.text;
                            },
                          ),
                          const SizedBox(height: Dimens.paddingMicro),
                          Text(state.providers[index].$1)
                        ],
                      );
                    },
                    itemCount: state.providers.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0));
                    },
                    // padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  );
                },
                valueListenable: state._selectedIndex,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AddWalletScreenState {
  final ValueNotifier<String> _mobileNumber = ValueNotifier('');
  final ValueNotifier<String> _provider = ValueNotifier('');
  final ValueNotifier<int> _selectedIndex = ValueNotifier(-1);
  final ValueNotifier<bool> _isButtonLoading = ValueNotifier(false);
  final ValueNotifier<bool> _isButtonEnabled = ValueNotifier(false);

  final CheckoutViewModel checkoutViewModel;

  AddWalletScreenState({required this.checkoutViewModel});

  final List<(String, String)> providers = [
    (CheckoutStrings.mtn.toUpperCase(), CheckoutDrawables.mtnMomo),
    (CheckoutStrings.vodafone.capitalize(), CheckoutDrawables.vodafoneCashLogo1),
    (CheckoutStrings.airtelDashTigo, CheckoutDrawables.airtelTigo),
  ];

  ValueNotifier<String> get mobileNumber => _mobileNumber;

  ValueNotifier<String> get provider => _provider;

  ValueNotifier<int> get selectedIndex => _selectedIndex;

  ValueNotifier<bool> get isButtonLoading => _isButtonLoading;

  ValueNotifier<bool> get isButtonEnabled => _isButtonEnabled;

  onNumberChanged(String value) {
    _mobileNumber.value = value;
    enableButton();
  }

  onProviderSelected(int index) {
    assert(index < providers.length);
    _provider.value = providers[index].$1;
    enableButton();
  }

  enableButton() {
    _isButtonEnabled.value =
        _provider.value.isNotEmpty && _mobileNumber.value.length >= 10;
  }

  onLoadingToggled() {
    _isButtonLoading.value = !_isButtonLoading.value;
  }

  Future<void> addWallet() async {
    // _isButtonLoading.value = true;
    // await Future.delayed(const Duration(seconds: 2)).then((value) {
    //   _isButtonLoading.value = false;
    // }).onError((error, stackTrace) => null);

    checkoutViewModel.fetchWallets().then((value) {
      value.data?.forEach((element) {
        log('$element', name: '$runtimeType');
      });
    }).onError((error, stackTrace) {
      log('$error', error: stackTrace, name: '$runtimeType');
    });
  }

  rest() {
    _mobileNumber.dispose();
    _provider.dispose();
    _selectedIndex.dispose();
    _isButtonLoading.dispose();
    _isButtonEnabled.dispose();
  }
}
