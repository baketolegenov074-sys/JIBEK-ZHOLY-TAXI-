/// Shared domain contract used by the passenger app, driver app and API.
enum JibekServiceType { cityTaxi, intercity, parcel, freight, towTruck, mobileTire }

enum JibekOrderStatus {
  draft,
  searching,
  accepted,
  driverArriving,
  inProgress,
  completed,
  cancelled,
}

class JibekGeoPoint {
  const JibekGeoPoint({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  final double latitude;
  final double longitude;
  final String? address;

  bool get isValid =>
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;

  Map<String, Object?> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        if (address != null) 'address': address,
      };

  factory JibekGeoPoint.fromJson(Map<String, Object?> json) =>
      JibekGeoPoint(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        address: json['address'] as String?,
      );
}

class JibekOrderRequest {
  const JibekOrderRequest({
    required this.id,
    required this.service,
    required this.pickup,
    required this.destination,
    required this.createdAt,
    this.vehicleClass,
    this.note,
    this.stops = const [],
    this.passengerId,
    this.status = JibekOrderStatus.draft,
    this.priceKzt = 250,
    this.boostCount = 0,
  });

  final String id;
  final JibekServiceType service;
  final JibekGeoPoint pickup;
  final JibekGeoPoint destination;
  final DateTime createdAt;
  final String? vehicleClass;
  final String? note;
  final List<JibekGeoPoint> stops;
  final String? passengerId;
  final JibekOrderStatus status;
  final int priceKzt;
  final int boostCount;
  bool get isBoosted => boostCount > 0;

  String? validate() {
    if (id.trim().isEmpty) return 'Не указан идентификатор заявки';
    if (!pickup.isValid || !destination.isValid) {
      return 'Координаты должны быть в допустимом диапазоне';
    }
    if (pickup.latitude == destination.latitude &&
        pickup.longitude == destination.longitude) {
      return 'Точки отправления и назначения совпадают';
    }
    if (stops.length > 1) return 'Можно добавить только одну остановку';
    for (final stop in stops) {
      if (!stop.isValid) return 'Координаты остановки указаны неверно';
      if ((stop.latitude == pickup.latitude && stop.longitude == pickup.longitude) ||
          (stop.latitude == destination.latitude && stop.longitude == destination.longitude)) {
        return 'Остановка должна отличаться от начала и конца маршрута';
      }
    }
    if (service == JibekServiceType.cityTaxi &&
        (vehicleClass == null || vehicleClass!.trim().isEmpty)) {
      return 'Для городского такси выберите класс автомобиля';
    }
    if ((service == JibekServiceType.parcel ||
            service == JibekServiceType.freight ||
            service == JibekServiceType.towTruck ||
            service == JibekServiceType.mobileTire) &&
        (note == null || note!.trim().isEmpty)) {
      return service == JibekServiceType.parcel
          ? 'Опишите посылку и что нужно доставить'
          : service == JibekServiceType.freight
              ? 'Опишите груз, габариты и адрес доставки'
              : service == JibekServiceType.towTruck
              ? 'Укажите автомобиль и характер поломки'
              : 'Укажите размер колёс и проблему';
    }
    return null;
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'service': service.name,
        'pickup': pickup.toJson(),
        'destination': destination.toJson(),
        'createdAt': createdAt.toUtc().toIso8601String(),
        if (vehicleClass != null) 'vehicleClass': vehicleClass,
        if (note != null) 'note': note,
        if (stops.isNotEmpty) 'stops': stops.map((point) => point.toJson()).toList(),
        if (passengerId != null) 'passengerId': passengerId,
        'status': status.name,
        'priceKzt': priceKzt,
        'boostCount': boostCount,
      };

  factory JibekOrderRequest.fromJson(Map<String, Object?> json) =>
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
        status: JibekOrderStatus.values.byName(
          json['status'] as String? ?? JibekOrderStatus.draft.name,
        ),
        priceKzt: (json['priceKzt'] as num?)?.toInt() ?? 250,
        boostCount: (json['boostCount'] as num?)?.toInt() ?? 0,
      );
}
