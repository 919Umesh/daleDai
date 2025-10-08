class EsewaPaymentModel {
  final String productId;
  final String productName;
  final String amount;
  final String? callbackUrl;

  EsewaPaymentModel({
    required this.productId,
    required this.productName,
    required this.amount,
    this.callbackUrl,
  });
}