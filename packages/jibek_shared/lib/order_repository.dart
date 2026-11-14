import 'dart:convert';

import 'package:http/http.dart' as http;

import 'order_models.dart';

/// API boundary. Implementations must use verified user identity.
abstract interface class JibekOrderRepository {
  Future<JibekOrderRequest> createOrder(JibekOrderRequest request);

  Future<JibekOrderRequest> getOrder({required String orderId});

  Future<JibekOrderRequest?> getActiveDriverOrder();

  Future<List<JibekOrderRequest>> getAvailableOrders({
    required Set<JibekServiceType> services,
  });

  Future<void> updateDriverPresence({
    required bool isOnline,
    required Set<JibekServiceType> services,
  });

  Future<JibekOrderRequest> acceptOrder({required String orderId});

  Future<JibekOrderRequest> boostOrder({required String orderId, int amountKzt = 250});

  Future<JibekOrderRequest> updateOrderStatus({
    required String orderId,
    required JibekOrderStatus status,
  });
}

/// Development-only adapter for the current API identity shim.
///
/// The server currently trusts X-Dev-User-Id. Never ship this adapter in a
/// public release. Replace it with a verified JWT/OIDC implementation first.
class DevJibekApiRepository implements JibekOrderRepository {
  DevJibekApiRepository({
    required String baseUrl,
    required Future<String> Function() devUserIdProvider,
    http.Client? client,
  })  : _baseUri = Uri.parse(baseUrl),
        _devUserIdProvider = devUserIdProvider,
        _client = client ?? http.Client();

  final Uri _baseUri;
  final Future<String> Function() _devUserIdProvider;
  final http.Client _client;

  Map<String, String> get _baseHeaders => {
        'Content-Type': 'application/json',
      };

  Future<Map<String, String>> _headers() async {
    final userId = (await _devUserIdProvider()).trim();
    if (userId.isEmpty) {
      throw const JibekApiException('Не задан тестовый пользователь');
    }
    return {..._baseHeaders, 'X-Dev-User-Id': userId};
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) =>
      _baseUri.resolve(path).replace(queryParameters: query);

  Future<Map<String, Object?>> _send(
    Future<http.Response> Function(Map<String, String>) request,
  ) async {
    final response = await request(await _headers());
    final Object? decoded =
        response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = decoded is Map ? decoded['detail'] : null;
      throw JibekApiException(
        detail?.toString() ?? 'Ошибка сервера (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
    if (decoded is! Map) {
      throw const JibekApiException('Сервер вернул неверный формат');
    }
    return Map<String, Object?>.from(decoded);
  }

  JibekOrderRequest _orderFromApi(Map<String, Object?> json) =>
      JibekOrderRequest(
        id: json['id'] as String,
        service: JibekServiceType.values.byName(json['service'] as String),
        pickup: JibekGeoPoint.fromJson(
          Map<String, Object?>.from(json['pickup'] as Map),
        ),
        destination: JibekGeoPoint.fromJson(
          Map<String, Object?>.from(json['destination'] as Map),
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
        vehicleClass: json['vehicleClass'] as String?,
        note: json['note'] as String?,
        stops: (json['stops'] as List<dynamic>? ?? const [])
            .map((item) => JibekGeoPoint.fromJson(Map<String, Object?>.from(item as Map)))
            .toList(growable: false),
        passengerId: json['passengerId'] as String?,
        status: JibekOrderStatus.values.byName(json['status'] as String),
        priceKzt: (json['priceKzt'] as num?)?.toInt() ?? 250,
        boostCount: (json['boostCount'] as num?)?.toInt() ?? 0,
      );

  Map<String, Object?> _createPayload(JibekOrderRequest order) => {
        'service': order.service.name,
        'pickup': order.pickup.toJson(),
        'destination': order.destination.toJson(),
        if (order.vehicleClass != null) 'vehicleClass': order.vehicleClass,
        if (order.note != null) 'note': order.note,
        if (order.stops.isNotEmpty)
          'stops': order.stops.map((point) => point.toJson()).toList(),
        'priceKzt': order.priceKzt,
      };

  @override
  Future<JibekOrderRequest> createOrder(JibekOrderRequest request) async {
    final json = await _send(
      (headers) => _client.post(
        _uri('/v1/orders'),
        headers: headers,
        body: jsonEncode(_createPayload(request)),
      ),
    );
    return _orderFromApi(json);
  }

  @override
  Future<JibekOrderRequest?> getActiveDriverOrder() async {
    final response = await _client.get(
      _uri('/v1/driver/orders/active'),
      headers: await _headers(),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final Object? decoded =
          response.body.isEmpty ? null : jsonDecode(response.body);
      final detail = decoded is Map ? decoded['detail'] : null;
      throw JibekApiException(
        detail?.toString() ?? 'Ошибка сервера (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
    if (response.body.trim() == 'null' || response.body.isEmpty) return null;
    final Object? decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const JibekApiException('Сервер вернул неверный формат заказа');
    }
    return _orderFromApi(Map<String, Object?>.from(decoded));
  }

  @override
  Future<JibekOrderRequest> getOrder({required String orderId}) async {
    final json = await _send(
      (headers) => _client.get(
        _uri('/v1/orders/$orderId'),
        headers: headers,
      ),
    );
    return _orderFromApi(json);
  }

  @override
  Future<List<JibekOrderRequest>> getAvailableOrders({
    required Set<JibekServiceType> services,
  }) async {
    if (services.isEmpty) return [];
    final query = <String, dynamic>{
      'services': services.map((service) => service.name).toList(),
    };
    final response = await _client.get(
      _uri('/v1/driver/orders/available', query),
      headers: await _headers(),
    );
    final Object? decoded = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = decoded is Map ? decoded['detail'] : null;
      throw JibekApiException(
        detail?.toString() ?? 'Ошибка сервера (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
    if (decoded is! List) {
      throw const JibekApiException('Сервер вернул неверный список заявок');
    }
    return decoded
        .map((item) => _orderFromApi(Map<String, Object?>.from(item as Map)))
        .toList(growable: false);
  }

  @override
  Future<void> updateDriverPresence({
    required bool isOnline,
    required Set<JibekServiceType> services,
  }) async {
    await _send(
      (headers) => _client.put(
        _uri('/v1/driver/presence'),
        headers: headers,
        body: jsonEncode({
          'isOnline': isOnline,
          'services': services.map((service) => service.name).toList(),
        }),
      ),
    );
  }

  @override
  Future<JibekOrderRequest> acceptOrder({required String orderId}) async {
    final json = await _send(
      (headers) => _client.post(
        _uri('/v1/orders/$orderId/accept'),
        headers: headers,
      ),
    );
    return _orderFromApi(json);
  }

  @override
  Future<JibekOrderRequest> boostOrder({required String orderId, int amountKzt = 250}) async {
    final json = await _send((headers) => _client.post(
      _uri('/v1/orders/$orderId/boost'), headers: headers,
      body: jsonEncode({'amountKzt': amountKzt}),
    ));
    return _orderFromApi(json);
  }

  @override
  Future<JibekOrderRequest> updateOrderStatus({
    required String orderId,
    required JibekOrderStatus status,
  }) async {
    final json = await _send(
      (headers) => _client.patch(
        _uri('/v1/orders/$orderId/status'),
        headers: headers,
        body: jsonEncode({'status': status.name}),
      ),
    );
    return _orderFromApi(json);
  }

  void close() => _client.close();
}

class JibekApiException implements Exception {
  const JibekApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
