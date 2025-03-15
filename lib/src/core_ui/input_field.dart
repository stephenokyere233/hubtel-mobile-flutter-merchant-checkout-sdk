import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core_ui.dart';

class InputField extends StatefulWidget {
  const InputField(
      {super.key,
      required this.hintText,
      this.onChanged,
      this.validator,
      this.prefixWidget,
      this.suffixWidget,
      this.onSuffixTap,
      this.onTap,
      this.showClearContentSuffixIcon = false,
      this.inputType,
      this.maxLength,
      this.maxLines,
      this.minLines,
      this.expands = false,
      this.autofocus = false,
      this.enabled = true,
      this.readOnly = false,
      this.hasFill = false,
      this.controller,
      this.contentPadding,
      this.inputFormatters,
      this.focusedBorder,
      this.focusBorderColor,
      this.isPassword = false});

  final String hintText;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final Function()? onSuffixTap;
  final VoidCallback? onTap;
  final Widget? prefixWidget;
  final Widget? suffixWidget;
  final TextInputType? inputType;
  final EdgeInsetsGeometry? contentPadding;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final bool showClearContentSuffixIcon;
  final bool expands;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final bool hasFill;
  final List<TextInputFormatter>? inputFormatters;
  final InputBorder? focusedBorder;
  final Color? focusBorderColor;
  final bool? isPassword;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  // Cache the decoration to prevent rebuilds
  late InputDecoration _cachedDecoration;

  @override
  void initState() {
    super.initState();
    _updateCachedDecoration();
  }

  @override
  void didUpdateWidget(InputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update the decoration if relevant properties changed
    if (oldWidget.hintText != widget.hintText ||
        oldWidget.prefixWidget != widget.prefixWidget ||
        oldWidget.suffixWidget != widget.suffixWidget ||
        oldWidget.showClearContentSuffixIcon !=
            widget.showClearContentSuffixIcon ||
        oldWidget.contentPadding != widget.contentPadding ||
        oldWidget.hasFill != widget.hasFill ||
        oldWidget.focusedBorder != widget.focusedBorder ||
        oldWidget.focusBorderColor != widget.focusBorderColor) {
      _updateCachedDecoration();
    }
  }

  void _updateCachedDecoration() {
    _cachedDecoration = InputDecoration(
      contentPadding: widget.contentPadding,
      hintText: widget.hintText,
      filled: true,
      fillColor: widget.hasFill
          ? HubtelColors.neutral.shade400
          : HubtelColors.neutral.shade50,
      focusedBorder: widget.focusedBorder ??
          OutlineInputBorder(
            borderSide: BorderSide(
                color: widget.focusBorderColor ?? HubtelColors.springGreen,
                width: 1),
            borderRadius: BorderRadius.circular(Dimens.inputBorderRadius),
          ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(Dimens.inputBorderRadius),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: HubtelColors.crimson, width: 1),
        borderRadius: BorderRadius.circular(Dimens.inputBorderRadius),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: HubtelColors.crimson, width: 1),
        borderRadius: BorderRadius.circular(Dimens.inputBorderRadius),
      ),
      prefixIcon: widget.prefixWidget != null
          ? Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimens.paddingDefault,
              ),
              child: widget.prefixWidget,
            )
          : null,
      suffixIcon: widget.showClearContentSuffixIcon
          ? IconButton(
              icon: Container(
                decoration: BoxDecoration(
                  color: HubtelColors.neutral.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.clear,
                  color: HubtelColors.neutral.shade50,
                  size: Dimens.iconSmall,
                ),
              ),
              onPressed: widget.onSuffixTap,
            )
          : widget.suffixWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: widget.key ?? UniqueKey(),
      onChanged: (value) {
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
      },
      validator: widget.validator,
      keyboardType: widget.inputType,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      expands: widget.expands,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      controller: widget.controller,
      onTap: widget.onTap,
      readOnly: widget.readOnly,
      inputFormatters: widget.inputFormatters,
      obscureText: widget.isPassword ?? false,
      onFieldSubmitted: (_) {},
      textInputAction: TextInputAction.none,
      onEditingComplete: () {},
      decoration: _cachedDecoration,
    );
  }
}

class MobileNumberInputPrefix extends StatelessWidget {
  const MobileNumberInputPrefix({super.key, required this.countryCode});

  final String countryCode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45,
      height: 30,
      child: Center(
          child: Text(
        countryCode,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      )),
    );
  }
}
