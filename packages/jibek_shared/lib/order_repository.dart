import 'order_models.dart';

/// API boundary. A production implementation must call the authenticated
/// backend; the mobile apps must never treat a local stub as a live dispatch.
abstract interface class JibekOrderRepository {
  Future<JibekOrderRequest> createOrder(JibekOrderRequest request);

  Future<List<JibekOrderRequest>> getAvailableOrders({
    required String driverId,
    required Set<JibekServiceType> services,
  });

  Future<JibekOrderRequest> updateOrderStatus({
    required String orderId,
    required JibekOrderStatus status,
  });
}
