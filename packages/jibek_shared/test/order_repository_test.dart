import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jibek_shared/jibek_shared.dart';

void main() {
  group('DevJibekApiRepository active driver order', () {
    test('restores active order and sends development identity header', () async {
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return http.Response(
          '{"id":"order-123","service":"cityTaxi",'
          '"pickup":{"latitude":42.3154,"longitude":69.5869,'
          '"address":"Шымкент"},'
          '"destination":{"latitude":42.32,"longitude":69.60,'
          '"address":"Центр"},'
          '"vehicleClass":"Эконом","note":null,'
          '"passengerId":"passenger-1","driverId":"driver-1",'
          '"status":"inProgress","createdAt":"2026-11-12T10:00:00Z"}',
          200,
        );
      });
      final repository = DevJibekApiRepository(
        baseUrl: 'https://api.example.test',
        devUserIdProvider: () async => 'driver-1',
        client: client,
      );

      final order = await repository.getActiveDriverOrder();

      expect(captured.url.path, '/v1/driver/orders/active');
      expect(captured.headers['X-Dev-User-Id'], 'driver-1');
      expect(order?.id, 'order-123');
      expect(order?.status, JibekOrderStatus.inProgress);
      repository.close();
    });

    test('returns null when driver has no active order', () async {
      final client = MockClient(
        (_) async => http.Response('null', 200),
      );
      final repository = DevJibekApiRepository(
        baseUrl: 'https://api.example.test',
        devUserIdProvider: () async => 'driver-1',
        client: client,
      );

      expect(await repository.getActiveDriverOrder(), isNull);
      repository.close();
    });

    test('rejects missing development identity before sending request', () async {
      var sent = false;
      final client = MockClient((_) async {
        sent = true;
        return http.Response('null', 200);
      });
      final repository = DevJibekApiRepository(
        baseUrl: 'https://api.example.test',
        devUserIdProvider: () async => '',
        client: client,
      );

      await expectLater(
        repository.getActiveDriverOrder(),
        throwsA(isA<JibekApiException>()),
      );
      expect(sent, isFalse);
      repository.close();
    });
  });
}
