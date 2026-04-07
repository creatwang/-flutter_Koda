class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.userId,
    required this.date,
    required this.totalQuantity,
  });

  final int id;
  final int userId;
  final DateTime date;
  final int totalQuantity;
}
