import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core_ui/core_ui.dart';
import '../resources/resources.dart';
import '../utils/utils.dart';
import 'ccontainer.dart';

class NewBankCardForm extends StatefulWidget {
  const NewBankCardForm({
    super.key,
    required this.onCardSaveChecked,
    required this.onNewCardNumberChanged,
    required this.onNewCardDateChanged,
    required this.onNewCardCvvChanged,
    required this.formKey,
    required this.cardNumberInputController,
    required this.cardDateInputController,
    required this.cardCvvInputController,
    this.cardNumberFocusNode,
    this.cardDateFocusNode,
    this.cardCvvFocusNode,
  });

  final TextEditingController cardNumberInputController;
  final TextEditingController cardDateInputController;
  final TextEditingController cardCvvInputController;

  final void Function(bool?) onCardSaveChecked;
  final void Function(String)? onNewCardNumberChanged;
  final void Function(String)? onNewCardDateChanged;
  final void Function(String)? onNewCardCvvChanged;
  final GlobalKey<FormState> formKey;

  final FocusNode? cardNumberFocusNode;
  final FocusNode? cardDateFocusNode;
  final FocusNode? cardCvvFocusNode;

  @override
  State<NewBankCardForm> createState() => _NewBankCardFormState();
}

class _NewBankCardFormState extends State<NewBankCardForm> {
  bool saveCardForFuture = false;
  String cardNumber = "";

  // Create internal focus nodes if not provided
  FocusNode? _internalCardNumberFocusNode;
  FocusNode? _internalCardDateFocusNode;
  FocusNode? _internalCardCvvFocusNode;

  FocusNode get _effectiveCardNumberFocusNode =>
      widget.cardNumberFocusNode ?? _internalCardNumberFocusNode!;

  FocusNode get _effectiveCardDateFocusNode =>
      widget.cardDateFocusNode ?? _internalCardDateFocusNode!;

  FocusNode get _effectiveCardCvvFocusNode =>
      widget.cardCvvFocusNode ?? _internalCardCvvFocusNode!;

  @override
  void initState() {
    super.initState();

    // Initialize internal focus nodes if needed
    if (widget.cardNumberFocusNode == null) {
      _internalCardNumberFocusNode = FocusNode();
    }

    if (widget.cardDateFocusNode == null) {
      _internalCardDateFocusNode = FocusNode();
    }

    if (widget.cardCvvFocusNode == null) {
      _internalCardCvvFocusNode = FocusNode();
    }

    // Add listeners to move focus when fields are complete
    widget.cardNumberInputController.addListener(_handleCardNumberChange);
    widget.cardDateInputController.addListener(_handleCardDateChange);
  }

  @override
  void dispose() {
    // Remove listeners
    widget.cardNumberInputController.removeListener(_handleCardNumberChange);
    widget.cardDateInputController.removeListener(_handleCardDateChange);

    // Dispose internal focus nodes
    _internalCardNumberFocusNode?.dispose();
    _internalCardDateFocusNode?.dispose();
    _internalCardCvvFocusNode?.dispose();

    super.dispose();
  }

  void _handleCardNumberChange() {
    // If card number is complete (16 digits + 3 spaces = 19 chars), move to date field
    if (widget.cardNumberInputController.text.length == 19) {
      Future.microtask(() {
        FocusScope.of(context).requestFocus(_effectiveCardDateFocusNode);
      });
    }
  }

  void _handleCardDateChange() {
    // If date is complete (MM/YY = 5 chars), move to CVV field
    if (widget.cardDateInputController.text.length == 5) {
      Future.microtask(() {
        FocusScope.of(context).requestFocus(_effectiveCardCvvFocusNode);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          InputField(
            controller: widget.cardNumberInputController,
            focusNode: _effectiveCardNumberFocusNode,
            hasFill: true,
            autofocus: true,
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 16) {
                return CheckoutStrings.invalidCardNumber;
              }
              return null;
            },
            onChanged: (val) {
              setState(() {
                cardNumber = val;
              });
              widget.onNewCardNumberChanged?.call(val);
            },
            hintText: CheckoutStrings.bankCardHintText,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              CardNumberInputFormatter(),
            ],
            inputType: const TextInputType.numberWithOptions(
              decimal: false,
              signed: false,
            ),
            onEditingComplete: () {
              // Prevent keyboard dismissal
              if (widget.cardNumberInputController.text.length < 19) {
                FocusScope.of(context)
                    .requestFocus(_effectiveCardNumberFocusNode);
              } else {
                FocusScope.of(context)
                    .requestFocus(_effectiveCardDateFocusNode);
              }
            },
            onFieldSubmitted: (_) {
              // Prevent keyboard dismissal
              if (widget.cardNumberInputController.text.length < 19) {
                FocusScope.of(context)
                    .requestFocus(_effectiveCardNumberFocusNode);
              } else {
                FocusScope.of(context)
                    .requestFocus(_effectiveCardDateFocusNode);
              }
            },
            suffixWidget: (cardNumber.startsWith("4") && cardNumber.length >= 3)
                ? CContainer(
                    padding: onlySidePad(right: Dimens.paddingDefault),
                    child: AppImageWidget.local(
                      image: const AssetImage(CheckoutDrawables.visa),
                      width: Dimens.iconMedium,
                      height: Dimens.iconSmall,
                      boxFit: BoxFit.contain,
                      borderRadius: 0,
                    ),
                  )
                : (cardNumber.startsWith("5") && cardNumber.length >= 3)
                    ? CContainer(
                        padding: onlySidePad(right: Dimens.paddingDefault),
                        child: AppImageWidget.local(
                          image: const AssetImage(CheckoutDrawables.masterCard),
                          width: Dimens.iconMedium,
                          height: Dimens.iconSmall,
                          boxFit: BoxFit.contain,
                          borderRadius: 0,
                        ),
                      )
                    : SizedBox.shrink(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(Dimens.inputBorderRadius),
            ),
            // contentPadding: symmetricPad(
            //   horizontal: AppDimens.paddingDefault,
            // ),
          ),
          const SizedBox(height: Dimens.paddingDefault),
          Row(
            children: [
              Expanded(
                child: InputField(
                  controller: widget.cardDateInputController,
                  focusNode: _effectiveCardDateFocusNode,
                  hasFill: true,
                  onTap: () {
                    FocusScope.of(context)
                        .requestFocus(_effectiveCardDateFocusNode);
                  },
                  hintText: CheckoutStrings.monthAndYearBankHint,
                  inputType: TextInputType.number,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(5),
                    CardExpiryFormatter(),
                  ],
                  onChanged: widget.onNewCardDateChanged,
                  onEditingComplete: () {
                    // Prevent keyboard dismissal
                    if (widget.cardDateInputController.text.length < 5) {
                      FocusScope.of(context)
                          .requestFocus(_effectiveCardDateFocusNode);
                    } else {
                      FocusScope.of(context)
                          .requestFocus(_effectiveCardCvvFocusNode);
                    }
                  },
                  onFieldSubmitted: (_) {
                    // Prevent keyboard dismissal
                    if (widget.cardDateInputController.text.length < 5) {
                      FocusScope.of(context)
                          .requestFocus(_effectiveCardDateFocusNode);
                    } else {
                      FocusScope.of(context)
                          .requestFocus(_effectiveCardCvvFocusNode);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 5)
                      return CheckoutStrings.invalidDateFormat;
                    return null;
                  },
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius:
                        BorderRadius.circular(Dimens.inputBorderRadius),
                  ),
                  // contentPadding: symmetricPad(
                  //   horizontal: AppDimens.paddingDefault,
                  // ),
                ),
              ),
              const SizedBox(width: Dimens.paddingDefault),
              Expanded(
                child: InputField(
                  isPassword: true,
                  maxLines: 1,
                  controller: widget.cardCvvInputController,
                  focusNode: _effectiveCardCvvFocusNode,
                  hasFill: true,
                  onTap: () {
                    FocusScope.of(context)
                        .requestFocus(_effectiveCardCvvFocusNode);
                  },
                  hintText: CheckoutStrings.cvv,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(3),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  inputType: const TextInputType.numberWithOptions(
                    signed: false,
                    decimal: false,
                  ),
                  onChanged: widget.onNewCardCvvChanged,
                  onEditingComplete: () {
                    // Prevent keyboard dismissal by maintaining focus
                    FocusScope.of(context)
                        .requestFocus(_effectiveCardCvvFocusNode);
                  },
                  onFieldSubmitted: (_) {
                    // Prevent keyboard dismissal by maintaining focus
                    FocusScope.of(context)
                        .requestFocus(_effectiveCardCvvFocusNode);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 3) {
                      return CheckoutStrings.invalidCardCvv;
                    }
                    return null;
                  },
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius:
                        BorderRadius.circular(Dimens.inputBorderRadius),
                  ),
                  // contentPadding: symmetricPad(
                  //   horizontal: AppDimens.paddingDefault,
                  // ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimens.paddingDefault),
          GestureDetector(
            onTap: () {
              setState(() {
                saveCardForFuture = !saveCardForFuture;
                widget.onCardSaveChecked(saveCardForFuture);
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(CheckoutStrings.saveCardForFuture,
                    style: AppTextStyle.body2()),
                CContainer(
                  padding: symmetricPad(
                    horizontal: Dimens.paddingDefaultMini,
                    vertical: Dimens.paddingDefaultMini,
                  ),
                  borderRadius: BorderRadius.circular(
                    Dimens.defaultBorderRadiusLarge,
                  ),
                  width: Dimens.radioButtonSize,
                  color: saveCardForFuture
                      ? ThemeConfig.themeColor
                      : HubtelColors.neutral.shade400,
                  child: AnimatedToggleSwitch<bool>.dual(
                      current: saveCardForFuture,
                      first: false,
                      second: true,
                      height: Dimens.defaultIconNormal,
                      indicatorSize: const Size(
                        Dimens.defaultIconNormal,
                        Dimens.defaultIconNormal,
                      ),
                      onChanged: (value) {
                        setState(() {
                          saveCardForFuture = value;
                          widget.onCardSaveChecked(value);
                        });
                      }),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
