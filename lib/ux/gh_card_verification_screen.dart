import 'package:flutter/material.dart';

import '../resources/checkout_strings.dart';
import 'components/app_bar.dart';
import 'components/buttons.dart';
import 'components/ghana_card.dart';
import 'components/verification_card.dart';

class GhanaCardVerificationScreen extends StatelessWidget {
  const GhanaCardVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HAppBar(
        title: CheckoutStrings.titleVerification,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            const Spacer(),
            const VerificationColumn(),
            const Spacer(),
            HBButton(label: CheckoutStrings.okay, onPressed: () {})
          ],
        ),
      ),
    );
  }
}

class VerificationColumn extends StatelessWidget {
  const VerificationColumn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 0.0),
      child: const Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          VerificationCard(),
          GhanaCard(),
        ],
      ),
    );
  }
}
