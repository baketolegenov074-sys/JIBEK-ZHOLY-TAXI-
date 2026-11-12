import 'order_models.dart';

/// API boundary. A production implementation must use verified user tokens.
abstract interface class JibekOrderRepository {
  Future<JibekOrderRequest> createOrder(JibekOrderRequest request);

  Future<List<JibekOrderRequest>> getAvailableOrders({
    required String driverId,
    required Set<JibekServiceType> services,
  });

  Future<JibekOrderRequest> acceptOrder({required String orderId});

  Future<JibekOrderRequest> updateOrderStatus({
    required String orderId,
    required JibekOrderStatus status,
  });
}
