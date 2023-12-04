
enum UnifiedCheckoutPaymentStatus {
  paymentFailed,
  paymentSuccess,
  pending,
  unknown,
  userCancelledPayment
}

class CheckoutCompletionStatus {
  UnifiedCheckoutPaymentStatus status;
  String transactionId;

  CheckoutCompletionStatus({required this.status, required this.transactionId});
}
