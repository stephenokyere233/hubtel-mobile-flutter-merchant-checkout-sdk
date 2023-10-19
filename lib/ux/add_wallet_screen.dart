
import 'package:flutter/material.dart';
import 'package:unified_checkout_sdk/core_ui/app_page.dart';
import 'package:unified_checkout_sdk/core_ui/dimensions.dart';
import 'package:unified_checkout_sdk/core_ui/input_field.dart';
import 'package:unified_checkout_sdk/core_ui/text_style.dart';
import 'package:unified_checkout_sdk/platform/models/wallet.dart';
import 'package:unified_checkout_sdk/resources/checkout_strings.dart';
import 'package:unified_checkout_sdk/utils/string_extensions.dart';
import 'package:unified_checkout_sdk/ux/viewModel/checkout_view_model.dart';

import '../core_ui/custom_button.dart';
import '../core_ui/hubtel_colors.dart';
import '../custom_components/circle_image.dart';
import '../resources/checkout_drawables.dart';

class AddWalletScreen extends StatefulWidget {
  AddWalletScreen({super.key});

  @override
  State<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  final _mobileNumberController = TextEditingController();

  final checkoutViewModel = CheckoutViewModel();

  final AddWalletScreenState state =
      AddWalletScreenState(checkoutViewModel: CheckoutViewModel());

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: CheckoutStrings.addWalletScreenTitle,
      titleStyle: AppTextStyle.headline3(),
      elevation: 0.1,
      bottomNavigation: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: AnimatedBuilder(
          animation: Listenable.merge([state]),
          builder: (BuildContext context, Widget? child) {
            return CustomButton(
              title: 'CONTINUE'.toUpperCase(),
              isEnabled: state.value.isButtonEnabled,
              buttonAction: () {
                state.addWallet();
              },
              loading: state.value.isButtonLoading,
              isDisabledBgColor: HubtelColors.lighterGrey,
              disabledTitleColor: HubtelColors.grey,
              style: HubtelButtonStyle.solid,
              isEnabledBgColor: ThemeConfig.themeColor,
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Dimens.paddingDefault),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: Dimens.paddingLarge,
            ),
            Text(
              CheckoutStrings.mobileMoneyNumber,
              style: AppTextStyle.body2(),
            ),
            const SizedBox(
              height: Dimens.paddingSmall,
            ),
            ValueListenableBuilder(
              builder: (context, uiModel, child) {
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
              valueListenable: state,
            ),
            const SizedBox(
              height: Dimens.paddingDefault,
            ),
            Text(
              CheckoutStrings.selectNetwork,
              style: AppTextStyle.body1(),
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
                            borderColor: state.value.selectedIndex == index
                                ? ThemeConfig.themeColor
                                : Colors.transparent.withOpacity(0.1),
                            onTap: () {
                              state.value.selectedIndex = index;
                              state.onProviderSelected(index);
                              state.value.mobileNumber =
                                  _mobileNumberController.value.text;
                            },
                          ),
                          const SizedBox(height: Dimens.paddingMicro),
                          Text(state.providers[index].$1, style: AppTextStyle.body1(),)
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
                valueListenable: state,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AddWalletUiModel {
  String _mobileNumber = '';
  String _provider = '';
  int _selectedIndex = -1;
  bool _isButtonLoading = false;
  bool _isButtonEnabled = false;
  bool _showLoadingDialog = false;
  List<Wallet> _wallets = [];

  String get mobileNumber => _mobileNumber;

  set mobileNumber(String value) {
    _mobileNumber = value;
  }

  String get provider => _provider;

  set provider(String value) {
    _provider = value;
  }

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int value) {
    _selectedIndex = value;
  }

  bool get isButtonLoading => _isButtonLoading;

  set isButtonLoading(bool value) {
    _isButtonLoading = value;
  }

  bool get isButtonEnabled => _isButtonEnabled;

  set isButtonEnabled(bool value) {
    _isButtonEnabled = value;
  }

  bool get showLoadingDialog => _showLoadingDialog;

  set showLoadingDialog(bool value) {
    _showLoadingDialog = value;
  }

  List<Wallet> get wallets => _wallets;

  set wallets(List<Wallet> value) {
    _wallets = value;
  }
}

class AddWalletScreenState extends ValueNotifier<AddWalletUiModel> {
  AddWalletScreenState({required this.checkoutViewModel})
      : super(AddWalletUiModel());

  CheckoutViewModel checkoutViewModel;

  final List<(String, String)> providers = [
    (CheckoutStrings.mtn.toUpperCase(), CheckoutDrawables.mtnMomo),
    (CheckoutStrings.vodafone.capitalize(), CheckoutDrawables.vodafoneCash),
    (CheckoutStrings.airtelDashTigo, CheckoutDrawables.airtelTigo),
  ];

  onNumberChanged(String number) {
    value.mobileNumber = number;
    enableButton();
  }

  onProviderSelected(int index) {
    assert(index < providers.length);
    value.provider = providers[index].$1;
    enableButton();
    notifyListeners();
  }

  enableButton() {
    value.isButtonEnabled =
        value.provider.isNotEmpty && value.mobileNumber.length >= 10;
    notifyListeners();
  }

  onLoadingToggled() {
    value.isButtonEnabled = !value.isButtonEnabled;
  }

  bool get isLoading => value.showLoadingDialog;

  Future<void> addWallet() async {
  }

  reset() {
    dispose();
  }
}
