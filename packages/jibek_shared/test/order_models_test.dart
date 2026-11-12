import 'package:flutter_test/flutter_test.dart';
import 'package:jibek_shared/jibek_shared.dart';

void main() {
  group('JibekOrderRequest', () {
    final pickup = JibekGeoPoint(
      latitude: 42.3154,
      longitude: 69.5869,
      address: 'Шымкент',
    );
    final destination = JibekGeoPoint(
      latitude: 42.32,
      longitude: 69.60,
      address: 'Шымкент, центр',
    );

    test('serializes and restores an order', () {
      final order = JibekOrderRequest(
        id: 'test-order-1',
        service: JibekServiceType.cityTaxi,
        pickup: pickup,
        destination: destination,
        createdAt: DateTime.utc(2026, 11, 12),
        vehicleClass: 'Эконом',
      );

      final restored = JibekOrderRequest.fromJson(order.toJson());

      expect(restored.id, order.id);
      expect(restored.service, JibekServiceType.cityTaxi);
      expect(restored.pickup.latitude, pickup.latitude);
      expect(restored.status, JibekOrderStatus.draft);
      expect(restored.validate(), isNull);
    });

    test('rejects identical pickup and destination', () {
      final order = JibekOrderRequest(
        id: 'test-order-2',
        service: JibekServiceType.intercity,
        pickup: pickup,
        destination: pickup,
        createdAt: DateTime.utc(2026, 11, 12),
      );

      expect(order.validate(), contains('совпадают'));
    });

    test('requires service details for parcel, tow truck and mobile tire', () {
      for (final service in [
        JibekServiceType.parcel,
        JibekServiceType.towTruck,
        JibekServiceType.mobileTire,
      ]) {
        final order = JibekOrderRequest(
          id: 'details-required',
          service: service,
          pickup: pickup,
          destination: destination,
          createdAt: DateTime.utc(2026, 11, 12),
        );
        expect(order.validate(), isNotNull);
      }
    });

    test('accepts service details for parcel, tow truck and mobile tire', () {
      for (final service in [
        JibekServiceType.parcel,
        JibekServiceType.towTruck,
        JibekServiceType.mobileTire,
      ]) {
        final order = JibekOrderRequest(
          id: 'details-present',
          service: service,
          pickup: pickup,
          destination: destination,
          createdAt: DateTime.utc(2026, 11, 12),
          note: 'Подробности заявки',
        );
        expect(order.validate(), isNull);
      }
    });

    test('requires vehicle class for city taxi', () {
      final order = JibekOrderRequest(
        id: 'test-order-3',
        service: JibekServiceType.cityTaxi,
        pickup: pickup,
        destination: destination,
        createdAt: DateTime.utc(2026, 11, 12),
      );

      expect(order.validate(), contains('класс автомобиля'));
    });
  });
}
