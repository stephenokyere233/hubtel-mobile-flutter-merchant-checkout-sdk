
enum UnifiedCheckoutPaymentStatus {
  paymentFailed,
  paymentSuccess,
  pending,
  unknown,
  userCancelledPayment
}

class CheckoutCompletionStatus {
  String status;
  String transactionId;

  CheckoutCompletionStatus({required this.status, required this.transactionId});
}
