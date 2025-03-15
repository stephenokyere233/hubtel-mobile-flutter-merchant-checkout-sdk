import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hubtel_merchant_checkout_sdk/hubtel_merchant_checkout_sdk.dart';
import 'package:hubtel_merchant_checkout_sdk/src/custom_components/mobile_money_tile_field.dart';
import 'package:hubtel_merchant_checkout_sdk/src/platform/models/otp_request_body.dart';
import 'package:hubtel_merchant_checkout_sdk/src/ux/otp_screen/otp_screen.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '/src/core_ui/core_ui.dart';
import '/src/custom_components/custom_components.dart';
import '/src/extensions/widget_extensions.dart';
import '/src/utils/custom_expansion_widget.dart' as customExpansion;
import '/src/ux/home/preapproval_confirm_success_screen.dart';
import '../../custom_components/payment_info_card.dart';
import '../../custom_components/show_selected_message.dart';
import '../../extensions/string_extensions.dart';
import '../../network_manager/network_manager.dart';
import '../../platform/models/models.dart';
import '../../resources/resources.dart';
import '../../utils/utils.dart';
import '../3ds/otp_3ds_screen.dart';
import '../bank_pay/bank_pay_receipt_screen.dart';
import '../gh_card/add_gh_card_screen.dart';
import '../gh_card/gh_card_verification_screen.dart';
import '../mandate/new_mandate_id_screen.dart';
import '../view_model/checkout_view_model.dart';
import 'check_status_screen.dart';

class CheckoutHomeScreen extends StatefulWidget {
  late final PurchaseInfo checkoutPurchase;

  late final BusinessInfo businessInfo;
  late final ThemeConfig? themeConfig;
  final List<BankCardData>? savedBankCards;
  String accessToken = '';

  late final Setup3dsResponse? threeDsResponse;

  CheckoutHomeScreen(
      {super.key,
      required this.checkoutPurchase,
      required this.businessInfo,
      this.themeConfig,
      this.savedBankCards});

  @override
  State<CheckoutHomeScreen> createState() => _CheckoutHomeScreenState2();
}

class _CheckoutHomeScreenState2 extends State<CheckoutHomeScreen> {
  late TextEditingController mobileNumberController;

  late TextEditingController momoProviderController;

  late TextEditingController savedCardNumberFieldController;

  TextEditingController cardNumberInputController = TextEditingController();

  TextEditingController cardDateInputController = TextEditingController();

  TextEditingController cardCvvInputController = TextEditingController();

  TextEditingController momoSelectorController = TextEditingController();

  TextEditingController anotherMomoSelectorController = TextEditingController();

  // Add focus nodes to maintain focus when typing
  final FocusNode mobileNumberFocusNode = FocusNode();
  final FocusNode cardNumberFocusNode = FocusNode();
  final FocusNode cardDateFocusNode = FocusNode();
  final FocusNode cardCvvFocusNode = FocusNode();

  late customExpansion.ExpansionTileController mobileMoneyExpansionController;

  late customExpansion.ExpansionTileController bankCardExpansionController;

  late customExpansion.ExpansionTileController
      otherPaymentWalletExpansionController;

  bool? isMobileMoneyExpanded;

  bool? shouldSaveCardForFuture;

  MomoProvider? selectedProvider;

  String? savedCardCvv;

  BankCardData? bankCard = BankCardData();

  String? newCardNumber;

  String? newCardExpiry;

  String? newCardCvv;

  WalletType? walletType;

  Wallet? selectedWallet;

  GlobalKey<FormState> newCardFormKey = GlobalKey<FormState>();

  GlobalKey<FormState> savedCardFormKey = GlobalKey<FormState>();

  List<BankCardData> savedCards = [];

  bool useNewCard = true;

  bool showWebView = false;

  bool didPreSelectMomoWallet = false;

  double? totalAmountPayable;

  List<Wallet> wallets = [];

  bool feesFetched = false;

  final checkoutHomeScreenState = _CheckoutHomeScreenState();

  bool preselectOtherMomoWallet = true;

  late final WebViewController controller;

  final viewModel = CheckoutViewModel();

  late customExpansion.ExpansionTileController bankPayExpansionController;

  bool isNewMandateIdChecked = false;

  late String otherProviderString =
      viewModel.getPaymentTypes()[0].provider ?? "";

  String paymentHtml = "";

  bool didPreselectWalletType = false;

  bool isWalletFetched = false;

  late final paymentOptionsAvailable = viewModel.getPaymentChannelsUI();

  // Add a form key for the main form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Store the card validation state to avoid unnecessary fetches
  bool _previousCardFormValid = false;

  @override
  initState() {
    super.initState();
    bankPayExpansionController = customExpansion.ExpansionTileController();
    mobileMoneyExpansionController = customExpansion.ExpansionTileController();
    bankCardExpansionController = customExpansion.ExpansionTileController();
    otherPaymentWalletExpansionController =
        customExpansion.ExpansionTileController();
    mobileNumberController = TextEditingController();
    momoProviderController = TextEditingController();

    savedCardNumberFieldController = TextEditingController();
    if ((CheckoutViewModel.channelFetch?.isHubtelInternalMerchant == true)) {
      fetchWallets()
          .then((value) => _handleWalletFetchCompletion(response: value));
    } else {
      isWalletFetched = true;
    }

    getBankCards();
    controller = WebViewController()
      ..loadHtmlString("<h1>mimi</h1>")
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'DeviceCollectionComplete',
        onMessageReceived: (message) {
          if (message.message == CheckoutHtmlState.loadingBegan.toString()) {
            showWebView = false;
            setState(() {});
            _checkoutInstantServiceWithBankCard(context);
            print('checkout succeeded successfully');
          } else if (message.message == CheckoutHtmlState.success.toString()) {
            print('checkout succeeded successfully');
            // TODO : Go back and go to the check status screen
          } else if (message.message == CheckoutHtmlState.htmlLoadingFailed) {
            if (!mounted) return;
            // widget.dismissDialog(context: context);

            widget.showErrorDialog(
              context: context,
              message: 'Something unexpected happened',
            );
          }
        },
      );

    // Add listeners that don't interfere with keyboard focus
    cardNumberInputController.addListener(() {
      onNewCardInputComplete();
    });
    cardDateInputController.addListener(() {
      onNewCardInputComplete();
    });
    cardCvvInputController.addListener(() {
      onNewCardInputComplete();
    });
    mobileNumberController.addListener(() {
      onMobileNumberKeyed();
    });

    // Configure focus nodes to ensure keyboard stays visible
    _configureFocusNodes();

    // Ensure keyboard is visible after a short delay
    Future.delayed(Duration(milliseconds: 500), () {
      // Request focus for the mobile number field to show keyboard
      if (!mobileNumberFocusNode.hasFocus && !cardNumberFocusNode.hasFocus) {
        FocusScope.of(context).requestFocus(mobileNumberFocusNode);
      }
    });
  }

  // Configure focus nodes to ensure keyboard stays visible
  void _configureFocusNodes() {
    // Configure mobile number focus node
    mobileNumberFocusNode.addListener(() {
      if (mobileNumberFocusNode.hasFocus) {
        _ensureKeyboardVisible();
      }
    });

    // Configure card number focus node
    cardNumberFocusNode.addListener(() {
      if (cardNumberFocusNode.hasFocus) {
        _ensureKeyboardVisible();
      }
    });

    // Configure card date focus node
    cardDateFocusNode.addListener(() {
      if (cardDateFocusNode.hasFocus) {
        _ensureKeyboardVisible();
      }
    });

    // Configure card CVV focus node
    cardCvvFocusNode.addListener(() {
      if (cardCvvFocusNode.hasFocus) {
        _ensureKeyboardVisible();
      }
    });
  }

  // Ensure keyboard is visible
  void _ensureKeyboardVisible() {
    // This forces the keyboard to stay visible by ensuring a focus node has focus
    Future.microtask(() {
      if (walletType == WalletType.Momo) {
        FocusScope.of(context).requestFocus(mobileNumberFocusNode);
      } else if (walletType == WalletType.Card) {
        if (cardNumberInputController.text.length < 19) {
          FocusScope.of(context).requestFocus(cardNumberFocusNode);
        } else if (cardDateInputController.text.length < 5) {
          FocusScope.of(context).requestFocus(cardDateFocusNode);
        } else if (cardCvvInputController.text.length < 3) {
          FocusScope.of(context).requestFocus(cardCvvFocusNode);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press
        final checkoutStatus = CheckoutCompletionStatus(
            status: UnifiedCheckoutPaymentStatus.userCancelledPayment,
            transactionId: "");
        Navigator.pop(context, checkoutStatus);
        return false; // Prevent default back navigation
      },
      child: Scaffold(
        body: AppPage(
            appBarBackgroundColor: HubtelColors.neutral.shade300,
            hideBackNavigation: true,
            pageDecoration: PageDecoration(
              backgroundColor: HubtelColors.neutral
                  .shade300, // Theme.of(context).scaffoldBackgroundColor,
            ),
            actions: [
              IconButton(
                onPressed: () {
                  final checkoutStatus = CheckoutCompletionStatus(
                      status: UnifiedCheckoutPaymentStatus.userCancelledPayment,
                      transactionId: "");
                  Navigator.pop(context, checkoutStatus);
                },
                icon: Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color: HubtelColors.neutral.shade900,
                  size: Dimens.mdIconSize,
                ),
              )
            ],
            elevation: 0,
            onBackPressed: () {},
            bottomNavigation: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(Dimens.paddingDefault),
              child: AnimatedBuilder(
                builder: (context, child) {
                  return CustomButton(
                    title: !(walletType == WalletType.BankPay)
                        ? '${CheckoutStrings.pay} ${(totalAmountPayable ?? widget.checkoutPurchase.amount).formatMoney()}'
                            .toUpperCase()
                        : "GENERATE INVOICE",
                    isEnabled: checkoutHomeScreenState.isButtonEnabled.value,
                    buttonAction: () {
                      checkout();
                    },
                    loading: checkoutHomeScreenState.isLoadingFees.value,
                    isDisabledBgColor: HubtelColors.lighterGrey,
                    disabledTitleColor: HubtelColors.grey,
                    style: HubtelButtonStyle.solid,
                    isEnabledBgColor: ThemeConfig.themeColor,
                  );
                },
                animation: Listenable.merge([
                  checkoutHomeScreenState.isButtonEnabled,
                  checkoutHomeScreenState.isLoadingFees
                ]),
              ),
            ),
            body: !isWalletFetched
                ? Center(
                    child: CircularProgressIndicator(
                    color: ThemeConfig.themeColor,
                  ))
                : Column(
                    children: [
                      SizedBox(
                          height: Dimens.zero,
                          width: Dimens.zero,
                          child: WebViewWidget(controller: controller)),
                      Expanded(
                        child: Form(
                          key: _formKey,
                          // Don't auto-validate as it can cause keyboard dismissal
                          autovalidateMode: AutovalidateMode.disabled,
                          // Prevent the form from unfocusing fields during validation
                          onChanged: () {
                            // Empty implementation to prevent default behavior
                          },
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                              children: [
                                const SizedBox(height: Dimens.paddingDefault),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimens.paddingDefault,
                                  ),
                                  child: ValueListenableBuilder(
                                    builder: (ctx, value, child) =>
                                        PaymentInfoCard(
                                      checkoutPurchase: widget.checkoutPurchase,
                                      checkoutFees: checkoutHomeScreenState
                                              .checkoutFees.value ??
                                          0.00,
                                      businessInfo: widget.businessInfo,
                                      totalAmountPayable: totalAmountPayable,
                                    ),
                                    valueListenable:
                                        checkoutHomeScreenState.checkoutFees,
                                  ),
                                ),
                                const SizedBox(height: Dimens.iconMediumLarge),
                                Card(
                                  margin: symmetricPad(
                                    horizontal: Dimens.paddingDefault,
                                  ),
                                  shadowColor: HubtelColors.neutral.shade300
                                      .withOpacity(0.1),
                                  elevation: 20,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      Dimens.buttonBorderRadius,
                                    ),
                                  ),
                                  color: HubtelColors.neutral,
                                  child: Container(
                                    width: double.maxFinite,
                                    padding: const EdgeInsets.only(
                                      top: Dimens.paddingDefault,
                                    ),
                                    decoration: BoxDecoration(
                                      color: HubtelColors.neutral.shade100,
                                      borderRadius: BorderRadius.circular(
                                          Dimens.buttonBorderRadius),
                                    ),
                                    child: Consumer<CheckoutViewModel>(
                                      builder: ((context, value, child) =>
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal:
                                                      Dimens.paddingDefault,
                                                ),
                                                child: Text(
                                                  CheckoutStrings.payWith,
                                                  style: AppTextStyle.body1()
                                                      .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                  height:
                                                      Dimens.paddingDefault),

                                              // Replace expandable tiles with tab view
                                              _buildPaymentMethodTabs(value),
                                            ],
                                          )),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: Dimens.paddingDefault),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
      ),
    );
  }

  // New method to build payment method tabs
  Widget _buildPaymentMethodTabs(CheckoutViewModel viewModel) {
    // Create a list of available payment methods
    List<Widget> tabs = [];
    List<Widget> tabContents = [];

    // Add Mobile Money tab if available
    if (paymentOptionsAvailable.showMomoField) {
      tabs.add(Tab(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.phone_android, size: 16),
            SizedBox(width: 4),
            Text('Mobile Money'),
          ],
        ),
      ));

      tabContents.add(_buildMobileMoneyTab(viewModel));
    }

    // Add Bank Card tab if available
    if (paymentOptionsAvailable.showBankField) {
      tabs.add(Tab(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.credit_card, size: 16),
            SizedBox(width: 4),
            Text('Bank Card'),
          ],
        ),
      ));

      tabContents.add(_buildBankCardTab());
    }

    // Add Other Payment tab if available
    if (paymentOptionsAvailable.showOtherPaymentsField) {
      tabs.add(Tab(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_wallet, size: 16),
            SizedBox(width: 4),
            Text('Other Wallets'),
          ],
        ),
      ));

      tabContents.add(_buildOtherPaymentsTab(viewModel));
    }

    // Add Bank Pay tab if available
    if (paymentOptionsAvailable.showBankPayField) {
      tabs.add(Tab(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance, size: 16),
            SizedBox(width: 4),
            Text('Bank Pay'),
          ],
        ),
      ));

      tabContents.add(_buildBankPayTab());
    }

    return DefaultTabController(
      length: tabs.length,
      initialIndex: 0,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: HubtelColors.neutral.shade200,
              borderRadius: BorderRadius.circular(Dimens.buttonBorderRadius),
            ),
            margin: EdgeInsets.symmetric(horizontal: Dimens.paddingDefault),
            child: TabBar(
              tabs: tabs,
              labelColor: ThemeConfig.themeColor,
              unselectedLabelColor: HubtelColors.neutral.shade700,
              indicator: BoxDecoration(
                color: HubtelColors.neutral.shade50,
                borderRadius: BorderRadius.circular(Dimens.buttonBorderRadius),
              ),
              onTap: (index) {
                // Handle tab selection
                setState(() {
                  if (index == 0 && paymentOptionsAvailable.showMomoField) {
                    walletType = WalletType.Momo;
                    Future.microtask(() {
                      FocusScope.of(context)
                          .requestFocus(mobileNumberFocusNode);
                    });
                  } else if (index ==
                          (paymentOptionsAvailable.showMomoField ? 1 : 0) &&
                      paymentOptionsAvailable.showBankField) {
                    walletType = WalletType.Card;
                    Future.microtask(() {
                      FocusScope.of(context).requestFocus(cardNumberFocusNode);
                    });
                  } else if (paymentOptionsAvailable.showOtherPaymentsField) {
                    // Other payments tab
                    changeWalletType(
                        viewModel.getPaymentTypes()[0].provider ?? "");
                    if (preselectOtherMomoWallet) {
                      preselectWallet();
                      preselectOtherMomoWallet = false;
                    }
                  } else if (paymentOptionsAvailable.showBankPayField) {
                    // Bank pay tab
                    walletType = WalletType.BankPay;
                  }

                  // Fetch fees for the selected payment method
                  Future.microtask(() => fetchFees());
                });
              },
            ),
          ),
          SizedBox(height: Dimens.paddingDefault),
          Container(
            padding: EdgeInsets.symmetric(horizontal: Dimens.paddingDefault),
            constraints: BoxConstraints(minHeight: 200),
            child: TabBarView(
              physics:
                  NeverScrollableScrollPhysics(), // Prevent swiping which can dismiss keyboard
              children: tabContents,
            ),
          ),
        ],
      ),
    );
  }

  // Mobile Money Tab Content
  Widget _buildMobileMoneyTab(CheckoutViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mobile Number Input
        MobileMoneyTileField(
          fieldController: mobileNumberController,
          hintText: "Enter mobile number",
          isReadOnly: false,
          focusNode: mobileNumberFocusNode,
          wallets: wallets,
          providers: viewModel.providers,
          onWalletSelected: (wallet) {
            selectedWallet = wallet;
            autoSelectProviderFromSelectedWallet();
            fetchFees();

            // Ensure focus is maintained
            _ensureKeyboardVisible();
          },
          onProviderSelected: (provider) {
            setState(() {
              log('selecting provider here ${provider.alias}');
              selectedProvider = provider;
              fetchFees();
            });

            // Ensure focus is maintained
            _ensureKeyboardVisible();
          },
          onWalletUpdateComplete: () {
            _updateWallets();

            // Ensure focus is maintained
            _ensureKeyboardVisible();
          },
        ),

        SizedBox(height: Dimens.paddingDefault),

        // Provider Selection
        InputField(
          controller: momoProviderController,
          hintText: "Select provider",
          readOnly: true,
          hasFill: true,
          onTap: () {
            // Show provider selection dialog
            _showProviderSelectionDialog(viewModel.providers);
          },
          suffixWidget: Icon(
            Icons.arrow_drop_down,
            color: HubtelColors.neutral.shade900,
          ),
        ),

        if (selectedProvider != null)
          Padding(
            padding: const EdgeInsets.only(top: Dimens.paddingDefault),
            child: showSelectedProviderMessage(
              selectedProvider: selectedProvider ?? MomoProvider(),
            ),
          ),
      ],
    );
  }

  // Bank Card Tab Content
  Widget _buildBankCardTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Saved Cards / New Card Toggle
        if (savedCards.isNotEmpty)
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      useNewCard = true;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: useNewCard
                          ? ThemeConfig.themeColor
                          : HubtelColors.neutral.shade200,
                      borderRadius:
                          BorderRadius.circular(Dimens.inputBorderRadius),
                    ),
                    child: Center(
                      child: Text(
                        "New Card",
                        style: TextStyle(
                          color: useNewCard
                              ? Colors.white
                              : HubtelColors.neutral.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      useNewCard = false;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !useNewCard
                          ? ThemeConfig.themeColor
                          : HubtelColors.neutral.shade200,
                      borderRadius:
                          BorderRadius.circular(Dimens.inputBorderRadius),
                    ),
                    child: Center(
                      child: Text(
                        "Saved Cards",
                        style: TextStyle(
                          color: !useNewCard
                              ? Colors.white
                              : HubtelColors.neutral.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

        SizedBox(height: Dimens.paddingDefault),

        // Card Form
        if (useNewCard || savedCards.isEmpty)
          NewBankCardForm(
            formKey: newCardFormKey,
            cardNumberInputController: cardNumberInputController,
            cardDateInputController: cardDateInputController,
            cardCvvInputController: cardCvvInputController,
            cardNumberFocusNode: cardNumberFocusNode,
            cardDateFocusNode: cardDateFocusNode,
            cardCvvFocusNode: cardCvvFocusNode,
            onCardSaveChecked: (value) {
              setState(() {
                shouldSaveCardForFuture = value;
              });
            },
            onNewCardNumberChanged: (value) {
              setState(() {
                newCardNumber = value.replaceAll(' ', '');
              });
            },
            onNewCardDateChanged: (value) {
              final newValue = value.replaceAll(' ', '');
              if (newCardExpiry != newValue) {
                setState(() {
                  newCardExpiry = newValue;
                });
              }
            },
            onNewCardCvvChanged: (value) {
              if (newCardCvv != value) {
                setState(() {
                  newCardCvv = value;
                });
              }
            },
          )
        else if (savedCards.isNotEmpty)
          // Saved Cards List
          Column(
            children: [
              // Dropdown for saved cards
              InputField(
                controller: savedCardNumberFieldController,
                hintText: "Select a saved card",
                readOnly: true,
                hasFill: true,
                onTap: () {
                  _showSavedCardsDialog();
                },
                suffixWidget: Icon(
                  Icons.arrow_drop_down,
                  color: HubtelColors.neutral.shade900,
                ),
              ),
              SizedBox(height: Dimens.paddingDefault),
              // CVV Input for saved card
              InputField(
                hintText: "Enter CVV",
                isPassword: true,
                hasFill: true,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(3),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                inputType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    savedCardCvv = value;
                  });
                },
              ),
            ],
          ),
      ],
    );
  }

  // Other Payments Tab Content
  Widget _buildOtherPaymentsTab(CheckoutViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Provider Selection
        InputField(
          controller: momoSelectorController,
          hintText: "Select payment provider",
          readOnly: true,
          hasFill: true,
          onTap: () {
            _showOtherPaymentProvidersDialog(viewModel.getPaymentTypes());
          },
          suffixWidget: Icon(
            Icons.arrow_drop_down,
            color: HubtelColors.neutral.shade900,
          ),
        ),

        SizedBox(height: Dimens.paddingDefault),

        // Account Number Input
        InputField(
          controller: anotherMomoSelectorController,
          hintText: "Enter account number",
          hasFill: true,
          inputType: TextInputType.phone,
        ),

        // G-Money Mandate ID Checkbox
        if (walletType == WalletType.GMoney)
          Padding(
            padding: const EdgeInsets.only(top: Dimens.paddingDefault),
            child: Row(
              children: [
                Checkbox(
                  value: isNewMandateIdChecked,
                  onChanged: (value) {
                    setState(() {
                      isNewMandateIdChecked = value ?? false;
                    });
                  },
                  activeColor: ThemeConfig.themeColor,
                ),
                Expanded(
                  child: Text(
                    "Use new mandate ID",
                    style: AppTextStyle.body2(),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Bank Pay Tab Content
  Widget _buildBankPayTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(Dimens.paddingDefault),
          decoration: BoxDecoration(
            color: HubtelColors.neutral.shade200,
            borderRadius: BorderRadius.circular(Dimens.inputBorderRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bank Pay",
                style: AppTextStyle.body1().copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Pay with your bank account. You will be redirected to your bank's website to complete the payment.",
                style: AppTextStyle.body2(),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: ThemeConfig.themeColor,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Make sure you have access to your bank's internet banking.",
                      style: AppTextStyle.body2().copyWith(
                        color: ThemeConfig.themeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to show provider selection dialog
  void _showProviderSelectionDialog(List<MomoProvider> providers) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Provider"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: providers.length,
            itemBuilder: (context, index) {
              final provider = providers[index];
              return ListTile(
                title: Text(provider.name ?? ""),
                onTap: () {
                  setState(() {
                    selectedProvider = provider;
                    momoProviderController.text = provider.name ?? "";
                  });
                  fetchFees();
                  Navigator.pop(context);

                  // Ensure focus is maintained
                  Future.microtask(() {
                    FocusScope.of(context).requestFocus(mobileNumberFocusNode);
                  });
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Helper method to show saved cards dialog
  void _showSavedCardsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Card"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: savedCards.length,
            itemBuilder: (context, index) {
              final card = savedCards[index];
              return ListTile(
                title: Text(
                    "**** **** **** ${card.cardNumber?.substring(card.cardNumber!.length - 4) ?? ""}"),
                subtitle: Text("Expires: ${card.cardExpiryDate ?? ""}"),
                onTap: () {
                  setState(() {
                    bankCard = card;
                    savedCardNumberFieldController.text =
                        "**** **** **** ${card.cardNumber?.substring(card.cardNumber!.length - 4) ?? ""}";
                  });
                  fetchFees(cardNumber: card.cardNumber);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Helper method to show other payment providers dialog
  void _showOtherPaymentProvidersDialog(List<dynamic> providers) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Provider"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: providers.length,
            itemBuilder: (context, index) {
              final provider = providers[index];
              return ListTile(
                title: Text(provider.accountName ?? ""),
                onTap: () {
                  setState(() {
                    momoSelectorController.text = provider.accountName ?? "";
                    otherProviderString = provider.provider ?? "";
                  });
                  selectedProvider = MomoProvider(alias: otherProviderString);
                  changeWalletType(otherProviderString);
                  fetchFees();
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void preselectMomoWallet() {
    if (wallets.isNotEmpty) {
      setState(() {
        selectedWallet = wallets[0];
        mobileNumberController.text = selectedWallet?.accountNo ?? '';
        momoProviderController.text =
            CheckoutUtils.mapApiWalletProviderNameToKnowName(
                providerName: selectedWallet?.provider ?? '');
        selectedProvider = MomoProvider(
          name: CheckoutUtils.mapApiWalletProviderNameToKnowName(
            providerName: selectedWallet?.provider ?? '',
          ),
        );
      });
    } else {
      setState(() {
        selectedProvider = viewModel.providers[0];
        momoProviderController.text =
            CheckoutUtils.mapApiWalletProviderNameToKnowName(
                providerName: selectedProvider?.alias ?? '');
      });
    }
  }

  void preselectWallet() {
    if (wallets.isNotEmpty) {
      setState(() {
        selectedWallet = wallets[0];
        anotherMomoSelectorController.text = selectedWallet?.accountNo ?? '';
      });
    }
    momoSelectorController.text =
        viewModel.getPaymentTypes()[0].accountName ?? "";
  }

  Future<void> onMomoTileExpansionChanged(bool value) async {
    if (value == true && !didPreSelectMomoWallet) {
      preselectMomoWallet();
      setState(() {
        didPreSelectMomoWallet = true;
      });
    }

    if (value == true) {
      setState(() {
        isMobileMoneyExpanded = true;
        walletType = WalletType.Momo;
      });
      mobileMoneyExpansionController.expand();
      bankCardExpansionController.collapse();

      if (paymentOptionsAvailable.showOtherPaymentsField) {
        otherPaymentWalletExpansionController.collapse();
      }
      if (paymentOptionsAvailable.showBankPayField) {
        bankPayExpansionController.collapse();
      }
    }
  }

  Future<void> onOtherTileExpansionChanged(bool value) async {
    if (value == true && !didPreSelectMomoWallet) {}
    if (value == true) {
      setState(() {
        changeWalletType(otherProviderString);
      });
      mobileMoneyExpansionController.collapse();
      bankCardExpansionController.collapse();
      otherPaymentWalletExpansionController.expand();
      if (paymentOptionsAvailable.showBankPayField) {
        bankPayExpansionController.collapse();
      }
      selectedProvider = MomoProvider(alias: otherProviderString);
      fetchFees();
    }
  }

  void autoSelectProviderFromSelectedWallet() {
    print("****\n\n\n ${selectedWallet?.provider} \n\n\n****");
    setState(() {
      if (wallets.isNotEmpty) {
        momoProviderController.text =
            CheckoutUtils.mapApiWalletProviderNameToKnowName(
                providerName: selectedWallet?.provider ?? '');
        selectedProvider = CheckoutUtils.getProvider(
            providerString: selectedWallet?.provider ?? '');
      } else {
        selectedProvider = CheckoutUtils.getProvider(
            providerString: selectedWallet?.provider ??
                momoProviderController.text.toLowerCase() ??
                '');
      }
    });
  }

  Future<UiResult<List<Wallet>>> fetchWallets() async {
    log('${CheckoutViewModel.channelFetch?.isHubtelInternalMerchant}',
        name: '$runtimeType');
    final response = await viewModel.fetchWallets();
    return response;
  }

  _updateWallets() async {
    final wallets = await fetchWallets();
    _handleWalletFetchCompletion(response: wallets);
  }

  _handleWalletFetchCompletion({required UiResult<List<Wallet>> response}) {
    if (response.state == UiState.success) {
      // Only update state if there's an actual change
      final newWallets = response.data ?? [];
      final hasWalletsChanged = wallets.isEmpty ||
          wallets.length != newWallets.length ||
          !isWalletFetched;

      if (hasWalletsChanged) {
        viewModel.wallets = newWallets;
        wallets = newWallets;
        isWalletFetched = true;
        // Force a rebuild only when necessary
        setState(() {});
      }
    } else {
      widget.showErrorDialog(
          context: context,
          message: response.message,
          onOkayTap: () => {Navigator.pop(context)});
    }
  }

  _handleButtonActivation() {
    if (walletType == WalletType.BankPay) {}
    if (feesFetched && mobileNumberController.text.trim().length >= 9) {
      checkoutHomeScreenState.isButtonEnabled.value = true;
      return;
    }

    if (walletType == WalletType.Card || walletType == WalletType.BankPay) {
      checkoutHomeScreenState.isButtonEnabled.value = true;
      return;
    }

    if (selectedWallet != null && selectedProvider != null) {
      checkoutHomeScreenState.isButtonEnabled.value = true;
      return;
    }
  }

  fetchFees({String? cardNumber}) async {
    // Don't access FocusScope here as it can cause keyboard dismissal

    // Set loading state only once at the beginning
    checkoutHomeScreenState.isLoadingFees.value = true;

    if (walletType == WalletType.Card) {
      selectedProvider = MomoProvider(
          name: CheckoutStrings.BankCard,
          alias: CheckoutStrings.getChannelNameForBankPayment(
              cardNumber ?? cardNumberInputController.text));
    }

    if (walletType == WalletType.BankPay) {
      selectedProvider = MomoProvider(
          name: CheckoutStrings.bankPay, alias: CheckoutStrings.bankPay);
    }

    final response = await viewModel.fetchFees(
        channel: selectedProvider?.receiveMoneyPromptValue ??
            selectedProvider?.alias ??
            '',
        amount: widget.checkoutPurchase.amount);

    if (!mounted) return;

    // Always set loading to false regardless of response
    checkoutHomeScreenState.isLoadingFees.value = false;

    if (response.state == UiState.success) {
      // Batch state updates together to minimize rebuilds
      final newFees = response.data?.fees?.toDouble();
      final newAmountPayable = response.data?.amountPayable;

      // Only update if values have changed
      if (checkoutHomeScreenState.checkoutFees.value != newFees ||
          totalAmountPayable != newAmountPayable) {
        checkoutHomeScreenState.checkoutFees.value = newFees;
        totalAmountPayable = newAmountPayable;

        // Set feesFetched flag to true only if it wasn't already
        if (!feesFetched) {
          feesFetched = true;
        }

        // Use Future.microtask to avoid interrupting the current build cycle
        // which can cause keyboard dismissal
        Future.microtask(() => _handleButtonActivation());
      }
    } else {
      // Show error dialog after a microtask to avoid keyboard dismissal
      Future.microtask(() =>
          widget.showErrorDialog(context: context, message: response.message));
    }
  }

  void changeWalletType(String channel) {
    print("entered-here");
    switch (channel.toLowerCase()) {
      case 'hubtel-gh':
        walletType = WalletType.Hubtel;
      case 'g-money':
        walletType = WalletType.GMoney;
      case 'zeepay':
        walletType = WalletType.Zeepay;
      default:
        break;
    }
  }

  void checkout() async {
    // Only unfocus if we're actually proceeding with checkout AND the button is enabled
    // This prevents keyboard dismissal during normal form interaction
    if (checkoutHomeScreenState.isButtonEnabled.value) {
      // Use a delay to ensure the button press is registered before unfocusing
      await Future.delayed(Duration(milliseconds: 100));
      // Only unfocus when we're actually proceeding with checkout
      FocusScope.of(context).unfocus();
    } else {
      // If the button is not enabled, don't unfocus - let the user continue typing
      return;
    }

    if (!(CheckoutViewModel.channelFetch?.isHubtelInternalMerchant ?? false) &&
        walletType == WalletType.Momo) {
      selectedWallet = Wallet(
          externalId: '',
          accountNo: mobileNumberController.text,
          accountName: 'mtn',
          providerId: '',
          provider: selectedProvider?.alias ?? '',
          type: '');
    }

    if ((viewModel.merchantRequiresKyc == true) &&
        walletType == WalletType.Momo) {
      _checkUserVerificationDetails();
    } else {
      if (walletType == WalletType.Momo ||
          walletType == WalletType.Zeepay ||
          walletType == WalletType.Hubtel) {
        payWithMomo();
      }

      if (walletType == WalletType.GMoney) {
        final mandateId = await viewModel.getCustomerMandateId();
        log('$mandateId', name: '$runtimeType');
        if (mandateId == null || isNewMandateIdChecked || mandateId.isEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewMandateIdScreen(
                momoRequest: getCheckoutRequest(),
              ),
            ),
          );
        } else {
          payWithMomo(mandateId: mandateId);
        }
      }

      if (walletType == WalletType.Card) {
        _setup();
      }

      if (walletType == WalletType.BankPay) {
        log('$walletType');
        payWithMomo();
      }
    }
  }

  _checkUserVerificationDetails() async {
    widget.showLoadingDialog(
        context: context, text: CheckoutStrings.pleaseWait);

    final result = await viewModel.checkVerificationStatus(
        mobileNumber: selectedWallet?.accountNo ?? '');

    if (!mounted) return;

    Navigator.pop(context);

    if (result.state == UiState.success) {
      switch (result.data?.getVerificationStatus()) {
        case VerificationStatus.verified:
          payWithMomo();
        default:
          final navigatorResult = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GhanaCardVerificationScreen(
                verificationResponse: result.data,
              ),
            ),
          );

          if (navigatorResult == true) {
            payWithMomo();
          }
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddGhCardScreen(
            mobileNumber: selectedWallet?.accountNo ?? '',
          ),
        ),
      );
    }
  }

  void getBankCards() async {
    final cards = await viewModel.getBankWallets();
    if (widget.savedBankCards?.isNotEmpty ?? false) {
      savedCards = widget.savedBankCards ?? [];
    }

    if (cards?.isNotEmpty == true) {
      savedCards = cards! + (widget.savedBankCards ?? []);
    }
    setState(() {});
  }

  _setup() async {
    final (String? expiryMonth, String? expiryYear) =
        newCardExpiry?.getExpiryInfo() ?? (null, null);
    final (String? savedCardExpiryMonth, String? savedCardExpiryYear) =
        bankCard?.cardExpiryDate?.getExpiryInfo() ?? (null, null);

    if (shouldSaveCardForFuture == true) {
      viewModel.saveBankWallet(
        BankCardData(
          cardNumber: newCardNumber,
          cardExpiryDate: newCardExpiry,
          cvv: newCardCvv,
        ),
      );
    }

    final dsRequest = SetupPayerAuthRequest(
      amount: widget.checkoutPurchase.amount,
      cardHolderName: '',
      cardNumber: bankCard?.cardNumber ?? newCardNumber ?? '',
      cvv: bankCard?.cvv ?? newCardCvv ?? '',
      expiryMonth: savedCardExpiryMonth ?? expiryMonth ?? '',
      expiryYear: savedCardExpiryYear ?? expiryYear ?? '',
      customerMsisdn: CheckoutRequirements.customerMsisdn,
      description: widget.checkoutPurchase.purchaseDescription,
      clientReference: widget.checkoutPurchase.clientReference,
      callbackUrl: CheckoutRequirements.callbackUrl,
    );

    widget.showLoadingDialog(
      context: context,
      text: CheckoutStrings.pleaseWait,
    );

    final apiResult = await viewModel.setupAccessBank(request: dsRequest);

    if (!context.mounted) return;

    if (apiResult.state == UiState.success) {
      widget.accessToken = apiResult.data?.accessToken ?? '';
      widget.threeDsResponse = apiResult.data ?? Setup3dsResponse();

      setState(() {
        paymentHtml = widget.threeDsResponse?.html ?? "";
        showWebView = true;

        controller.loadHtmlString(
          widget.threeDsResponse?.html?.replaceVariable(
                  "CONTROL_RETURN_IDENTIFIER",
                  "DeviceCollectionComplete.postMessage('${CheckoutHtmlState.loadingBegan}')") ??
              "",
        );
      });
    } else {
      Navigator.pop(context);

      widget.showErrorDialog(
        context: context,
        message: apiResult.message,
      );
    }

    bankCard = null;
  }

  _checkoutInstantServiceWithBankCard(BuildContext context) async {
    final result = await viewModel.enrollAccessBank(
        transactionId: widget.threeDsResponse?.transactionId ?? '');

    if (!mounted) return;
    print(result.data?.html?.replaceVariable("CONTROL_RETURN_IDENTIFIER",
        "TransactionComplete.postMessage('${CheckoutHtmlState.transactionComplete}')"));
    if (result.state == UiState.success) {
      Navigator.pop(context);

      final webViewCheckoutData = WebCheckoutPageData(
          jwt: result.data?.jwt ?? '',
          orderId: result.data?.transactionId ?? "",
          reference: result.data?.clientReference ?? '',
          customData: result.data?.customData ?? '',
          html: result.data?.html?.replaceVariable("CONTROL_RETURN_IDENTIFIER",
              "TransactionComplete.postMessage('${CheckoutHtmlState.transactionComplete}')"));

      final onBankCallbackReceived = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  CheckoutWebViewWidget(pageData: webViewCheckoutData)));

      if (onBankCallbackReceived == true) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CheckStatusScreen(
                    checkoutResponse: MomoResponse(
                        transactionId: widget.threeDsResponse?.transactionId,
                        clientReference:
                            widget.threeDsResponse?.clientReference))));
      }
    } else {
      Navigator.pop(context);

      widget.showErrorDialog(
        context: context,
        message: result.message,
      );
    }
  }

  void onCheckoutCompleted(MomoResponse? momoResponse, BuildContext context) {
    if (momoResponse?.skipOtp == false) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VerifyOtp(
                      pageData: VerifyOTPPageData(
                    phoneNumber: "",
                    requestId: '',
                    prefix: momoResponse?.otpPrefix ?? "",
                    amount: momoResponse?.amount ?? 0.00,
                    clientReference: momoResponse?.clientReference ?? "",
                    hubtelPreApprovalId:
                        momoResponse?.hubtelPreapprovalId ?? "",
                  ))));
      return;
    }

    if (walletType == WalletType.Momo) {
      if (CheckoutViewModel.checkoutType == CheckoutType.receivemoneyprompt) {
        widget.showPromptDialog(
            context: context,
            title: CheckoutStrings.success,
            buttonTitle: CheckoutStrings.okay,
            subtitle: CheckoutStrings.getPaymentPromptMessage(
                walletNumber: selectedWallet?.accountNo ?? ''),
            buttonAction: () {
              Navigator.pop(context);
              // Goto Transaction Status Screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckStatusScreen(
                    checkoutResponse: momoResponse ?? MomoResponse(),
                    themeConfig: widget.themeConfig,
                  ),
                ),
              );
            });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CheckStatusScreen(
              checkoutResponse: momoResponse ?? MomoResponse(),
              themeConfig: widget.themeConfig,
            ),
          ),
        );
      }
    } else if (walletType == WalletType.BankPay) {
      print('Fetching logo ${viewModel.channelResponse?.businessLogoUrl}');
      final businessRequirements = HtmlRequirements(
          imageUrl: CheckoutViewModel.channelFetch?.businessLogoUrl ?? '',
          clientName: momoResponse?.customerName ?? '',
          customerMsisdn: momoResponse?.customerMsisdn ?? '',
          slipId: momoResponse?.invoiceNumber ?? '',
          email: momoResponse?.email ?? '',
          businessName: CheckoutViewModel.channelFetch?.businessName ?? '');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BankPayReceiptScreen(
              mobileMoneyResponse: momoResponse ?? MomoResponse(),
              businessDetails: businessRequirements),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckStatusScreen(
            checkoutResponse: momoResponse ?? MomoResponse(),
            themeConfig: widget.themeConfig,
          ),
        ),
      );
    }
  }

  void makeGetOtpRequest({required OtpRequestBody requestBody}) async {
    widget.showLoadingDialog(
        context: context, text: CheckoutStrings.pleaseWait);

    final result = await viewModel.getOtp(requestBody: requestBody);

    if (!mounted) return;
    Navigator.pop(context);

    if (result.state == UiState.success) {
      final onOtpDone = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyOtp(
            pageData: VerifyOTPPageData(
              phoneNumber: requestBody.customerMsisdn,
              requestId: result.data?.requestId ?? "",
              prefix: result.data?.otpPrefix ?? "",
              amount: widget.checkoutPurchase.amount,
              clientReference: widget.checkoutPurchase.clientReference,
              hubtelPreApprovalId: "",
            ),
          ),
        ),
      );

      print(onOtpDone);
      if (onOtpDone == true) {
        payWithMomo(otpDone: true);
      }
    } else {}
  }

  void makePreApprovalConfirmRequest() async {
    if (CheckoutViewModel.checkoutType == CheckoutType.preapprovalconfirm) {
      final preApprovalConfirmParam = PreapprovalConfirm.create(
          selectedProvider?.directDebitValue ?? '',
          '${widget.checkoutPurchase.amount}',
          widget.checkoutPurchase.clientReference,
          mobileNumberController.text.trim(),
          widget.checkoutPurchase.purchaseDescription);
      widget.showLoadingDialog(
          context: context, text: CheckoutStrings.pleaseWait);
      final result = await viewModel.makePreApprovalConfirm(
          params: preApprovalConfirmParam);

      if (!mounted) return;

      Navigator.pop(context);

      if (result.state == UiState.success) {
        if (result.data?.preapprovalStatus?.toLowerCase() == 'approved') {
          //TODO: Go to preapproval confirmation screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PreApprovalConfirmSuccessScreen(
                walletName: 'mobile wallet',
                amount: widget.checkoutPurchase.amount,
              ),
            ),
          );
        } else {
          //TODO: Go to pending screen
        }
      } else {
        widget.showErrorDialog(context: context, message: result.message);
      }

      return;
    }
  }

  void payWithMomo({String? mandateId, bool otpDone = false}) async {
    if (CheckoutViewModel.channelFetch?.requireMobileMoneyOTP == true &&
        !otpDone &&
        walletType == WalletType.Momo) {
      final request =
          OtpRequestBody(customerMsisdn: selectedWallet?.accountNo ?? "");
      makeGetOtpRequest(requestBody: request);
      return;
    }

    if (CheckoutViewModel.checkoutType == CheckoutType.preapprovalconfirm &&
        !(selectedProvider?.alias == "airtelTigo") &&
        !(selectedProvider?.alias == "hubtel-gh")) {
      makePreApprovalConfirmRequest();
      return;
    }

    final request = getCheckoutRequest(mandateId: mandateId);
    widget.showLoadingDialog(
        context: context, text: CheckoutStrings.pleaseWait);

    final result = await viewModel.payWithMomo(req: request);

    if (!mounted) return;

    Navigator.pop(context);
    if (result.state == UiState.success) {
      final checkoutResponse = result.data;
      onCheckoutCompleted(result.data, context);
    } else {
      widget.showErrorDialog(context: context, message: result.message);
    }
  }

  MobileMoneyPaymentRequest getCheckoutRequest({String? mandateId}) {
    log('Callback: ${CheckoutRequirements.callbackUrl}', name: '$runtimeType');
    if (walletType == WalletType.Momo) {
      if (CheckoutViewModel.checkoutType == CheckoutType.receivemoneyprompt) {
        return MobileMoneyPaymentRequest(
            customerName: '',
            customerMsisdn: selectedWallet?.accountNo ?? '',
            channel: selectedProvider?.receiveMoneyPromptValue ?? '',
            amount: '${widget.checkoutPurchase.amount ?? 0.00}',
            primaryCallbackUrl: CheckoutRequirements.callbackUrl,
            description: widget.checkoutPurchase.purchaseDescription ?? "",
            clientReference: widget.checkoutPurchase.clientReference,
            mandateId: '');
      } else if (CheckoutViewModel.checkoutType == CheckoutType.directdebit) {
        return MobileMoneyPaymentRequest(
            customerName: '',
            customerMsisdn: selectedWallet?.accountNo ?? '',
            channel: selectedProvider?.directDebitValue ?? '',
            amount: '${widget.checkoutPurchase.amount ?? 0.00}',
            primaryCallbackUrl: CheckoutRequirements.callbackUrl,
            description: widget.checkoutPurchase.purchaseDescription ?? "",
            clientReference: widget.checkoutPurchase.clientReference,
            mandateId: '');
      }
    } else if (walletType == WalletType.Hubtel) {
      final hubtelWallet = wallets
          .firstWhere((element) => element.provider?.toLowerCase() == 'hubtel');
      return MobileMoneyPaymentRequest(
          customerName: '',
          customerMsisdn: hubtelWallet.accountNo ?? '',
          channel: 'hubtel-gh',
          amount: '${widget.checkoutPurchase.amount ?? 0.00}',
          primaryCallbackUrl: CheckoutRequirements.callbackUrl,
          description: widget.checkoutPurchase.purchaseDescription ?? "",
          clientReference: widget.checkoutPurchase.clientReference,
          mandateId: '');
    } else if (walletType == WalletType.GMoney) {
      return MobileMoneyPaymentRequest(
          customerName: '',
          customerMsisdn: selectedWallet?.accountNo ?? '',
          channel: 'g-money',
          amount: '${widget.checkoutPurchase.amount ?? 0.00}',
          primaryCallbackUrl: CheckoutRequirements.callbackUrl,
          description: widget.checkoutPurchase.purchaseDescription ?? "",
          clientReference: widget.checkoutPurchase.clientReference,
          mandateId: mandateId ?? '');
    } else if (walletType == WalletType.Zeepay) {
      return MobileMoneyPaymentRequest(
          customerName: '',
          customerMsisdn: selectedWallet?.accountNo ?? '',
          channel: 'zeepay',
          amount: '${widget.checkoutPurchase.amount ?? 0.00}',
          primaryCallbackUrl: CheckoutRequirements.callbackUrl,
          description: widget.checkoutPurchase.purchaseDescription ?? '',
          clientReference: widget.checkoutPurchase.clientReference,
          mandateId: '');
    } else if (walletType == WalletType.BankPay) {
      return MobileMoneyPaymentRequest(
          customerName: '',
          customerMsisdn: CheckoutRequirements.customerMsisdn,
          channel: 'bankpay',
          amount: '${widget.checkoutPurchase.amount ?? 0.00}',
          primaryCallbackUrl: CheckoutRequirements.callbackUrl,
          description: widget.checkoutPurchase.purchaseDescription ?? '',
          clientReference: widget.checkoutPurchase.clientReference,
          mandateId: '');
    }

    return MobileMoneyPaymentRequest();
  }

  void onNewCardInputComplete() {
    // Don't access FocusScope here as it can cause keyboard dismissal

    final isCardNumberInputComplete =
        cardNumberInputController.text.trim().isNotEmpty &&
            cardNumberInputController.text.characters.length == 22;

    final isCardDateInputComplete =
        cardDateInputController.text.trim().isNotEmpty &&
            cardDateInputController.text.length == 5;

    final isCardCvvInputComplete =
        cardCvvInputController.text.trim().isNotEmpty &&
            cardCvvInputController.text.length == 3;

    final isCurrentlyValid = isCardNumberInputComplete &&
        isCardDateInputComplete &&
        isCardCvvInputComplete;

    // Only fetch fees if the form just became valid and wasn't valid before
    if (isCurrentlyValid && !_previousCardFormValid) {
      // Use Future.microtask to avoid interrupting the current build cycle
      // which can cause keyboard dismissal
      Future.microtask(() => fetchFees());
    }

    _previousCardFormValid = isCurrentlyValid;

    // Ensure focus is maintained on the appropriate field
    Future.microtask(() {
      if (!isCardNumberInputComplete) {
        FocusScope.of(context).requestFocus(cardNumberFocusNode);
      } else if (!isCardDateInputComplete) {
        FocusScope.of(context).requestFocus(cardDateFocusNode);
      } else if (!isCardCvvInputComplete) {
        FocusScope.of(context).requestFocus(cardCvvFocusNode);
      }
    });
  }

  void onMobileNumberKeyed() {
    // Don't access FocusScope here as it can cause keyboard dismissal

    final isValid = mobileNumberController.text.trim().length >= 9;
    final currentButtonState = checkoutHomeScreenState.isButtonEnabled.value;

    // Only update state if there's an actual change in the button state
    if (isValid != currentButtonState) {
      if (isValid) {
        // Use Future.microtask to avoid interrupting the current build cycle
        // which can cause keyboard dismissal
        Future.microtask(() => _handleButtonActivation());
      } else {
        checkoutHomeScreenState.isButtonEnabled.value = false;
      }
    }

    // Ensure the focus is maintained on the mobile number field
    if (!mobileNumberFocusNode.hasFocus) {
      Future.microtask(
          () => FocusScope.of(context).requestFocus(mobileNumberFocusNode));
    }
  }

  @override
  void dispose() {
    cardNumberInputController.removeListener(() {
      onNewCardInputComplete();
    });
    cardDateInputController.removeListener(() {
      onNewCardInputComplete();
    });
    cardCvvInputController.removeListener(() {
      onNewCardInputComplete();
    });
    mobileNumberController.removeListener(() {
      onMobileNumberKeyed();
    });

    // Dispose of focus nodes
    mobileNumberFocusNode.dispose();
    cardNumberFocusNode.dispose();
    cardDateFocusNode.dispose();
    cardCvvFocusNode.dispose();

    super.dispose();
  }
}

class _CheckoutHomeScreenState {
  final ValueNotifier<double?> _checkoutFees = ValueNotifier(null);
  final ValueNotifier<bool> _isButtonEnabled = ValueNotifier(false);
  final ValueNotifier<bool> _isLoadingFees = ValueNotifier(false);
  final ValueNotifier<String> _selectedChannel = ValueNotifier('Hubtel');

  ValueNotifier<double?> get checkoutFees => _checkoutFees;

  ValueNotifier<bool> get isButtonEnabled => _isButtonEnabled;

  ValueNotifier<bool> get isLoadingFees => _isLoadingFees;

  ValueNotifier<String> get selectedChannel => _selectedChannel;
}

extension StringExtensions on String {
  String replaceVariable(String variableName, String value) {
    return replaceAll(variableName, value);
  }
}
