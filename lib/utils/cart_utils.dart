double calculateCartTotal(List<Map<String, dynamic>> cartItems) {
  return cartItems.fold(0.0, (sum, item) {
    final price = (item['price'] ?? 0).toDouble();
    final qty = (item['qty'] ?? 1).toDouble();
    return sum + (price * qty);
  });
}
