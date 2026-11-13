// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jibek_shared/jibek_shared.dart';
import 'package:latlong2/latlong.dart';

void main() => runApp(const JibekDriverApp());

class JibekDriverApp extends StatelessWidget {
  const JibekDriverApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'ЖІБЕК ЖОЛЫ — Водитель',
        debugShowCheckedModeBanner: false,
        theme: JibekTheme.light(),
        home: const DriverMapPage(),
      );
}

class DriverMapPage extends StatefulWidget {
  const DriverMapPage({super.key});

  @override
  State<DriverMapPage> createState() => _DriverMapPageState();
}

class _DriverMapPageState extends State<DriverMapPage> {
  final MapController _mapController = MapController();
  final LatLng _shymkent = const LatLng(42.3154, 69.5869);
  LatLng? _driverPoint;
  bool _online = false;
  bool _loadingLocation = false;
  final Set<String> _services = {'Такси'};
  List<JibekOrderRequest> _orders = [];
  JibekOrderRequest? _activeOrder;
  bool _loadingOrders = false;
  static const _apiUrl = String.fromEnvironment('JIBEK_API_URL');
  static const _devUserId = String.fromEnvironment('JIBEK_DEV_USER_ID');

  Future<void> _locateDriver() async {
    setState(() => _loadingLocation = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _notice('Включите геолокацию в настройках телефона');
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _notice('Для отображения вашей точки разрешите геолокацию');
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      final point = LatLng(position.latitude, position.longitude);
      setState(() => _driverPoint = point);
      _mapController.move(point, 15);
    } catch (_) {
      _notice('Не удалось определить местоположение');
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  void _notice(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = _driverPoint == null
        ? <Marker>[]
        : [
            Marker(
              point: _driverPoint!,
              width: 52,
              height: 52,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(color: Color(0x44000000), blurRadius: 12),
                  ],
                ),
                child: const Icon(
                  Icons.local_taxi_rounded,
                  color: Color(0xFF0B192C),
                  size: 29,
                ),
              ),
            ),
          ];

    const navy = Color(0xFF0B192C);
    const yellow = Color(0xFFFFC107);

    return Scaffold(
      backgroundColor: navy,
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _shymkent,
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'kz.jibekzholy.driverapp',
                ),
                MarkerLayer(markers: markers),
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('© OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: navy,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: yellow, width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x55000000),
                          blurRadius: 16,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.directions_car_filled_rounded,
                          color: yellow,
                          size: 28,
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ЖІБЕК ЖОЛЫ',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'КАБИНЕТ ВОДИТЕЛЯ',
                              style: TextStyle(
                                color: yellow,
                                fontSize: 9,
                                letterSpacing: .8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: navy,
                    shape: const CircleBorder(),
                    elevation: 5,
                    child: IconButton(
                      tooltip: 'Моё местоположение',
                      onPressed: _loadingLocation ? null : _locateDriver,
                      icon: _loadingLocation
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: yellow,
                              ),
                            )
                          : const Icon(
                              Icons.my_location_rounded,
                              color: yellow,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          DraggableScrollableSheet(
            initialChildSize: .49,
            minChildSize: .36,
            maxChildSize: .84,
            snap: true,
            snapSizes: const [.49, .84],
            builder: (context, controller) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x44000000),
                    blurRadius: 22,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8DEE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Рабочая смена',
                              style: TextStyle(
                                color: navy,
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Управляйте выходом на линию и заказами',
                              style: TextStyle(
                                color: Color(0xFF778395),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4D1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.local_taxi_rounded,
                          color: navy,
                          size: 26,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: navy,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: yellow, width: 1),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _online ? 'Вы на линии' : 'Вы не на линии',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _online
                                    ? 'Вы доступны для новых заказов'
                                    : 'Включите статус, когда будете готовы',
                                style: const TextStyle(
                                  color: Color(0xFFD5DCE7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _online,
                          activeColor: yellow,
                          onChanged: _loadingOrders ? null : _setOnline,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Какие заказы выполнять?',
                    style: TextStyle(
                      color: navy,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _serviceChip('Такси', Icons.local_taxi_rounded),
                      _serviceChip('Межгород', Icons.route_rounded),
                      _serviceChip('Посылки', Icons.inventory_2_rounded),
                      _serviceChip('Эвакуатор', Icons.car_crash_rounded),
                      _serviceChip('Шиномонтаж', Icons.tire_repair_rounded),
                    ],
                  ),

                  const SizedBox(height: 22),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Новые заказы',
                          style: TextStyle(
                            color: navy,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Обновить заказы',
                        onPressed:
                            _loadingOrders || !_online ? null : _refreshOrders,
                        icon: const Icon(Icons.refresh_rounded, color: navy),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (_loadingOrders)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: CircularProgressIndicator(color: navy),
                      ),
                    ),

                  if (_activeOrder != null) _activeOrderCard(_activeOrder!),
                  ..._orders.map(_orderCard),

                  if (_orders.isEmpty && !_loadingOrders)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 25,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5EAF0)),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.inbox_outlined,
                            size: 38,
                            color: Color(0xFF9AA5B2),
                          ),
                          const SizedBox(height: 9),
                          const Text(
                            'Пока нет заявок',
                            style: TextStyle(
                              color: navy,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _online
                                ? 'Нажмите обновить, чтобы проверить новые заявки.'
                                : 'Включите режим на линии, чтобы получать заявки.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF778395),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Set<JibekServiceType> get _selectedServices {
    const mapping = {
      'Такси': JibekServiceType.cityTaxi,
      'Межгород': JibekServiceType.intercity,
      'Посылки': JibekServiceType.parcel,
      'Эвакуатор': JibekServiceType.towTruck,
      'Шиномонтаж': JibekServiceType.mobileTire,
    };
    return _services.map((label) => mapping[label]!).toSet();
  }

  Future<void> _setOnline(bool value) async {
    if (_apiUrl.isEmpty || _devUserId.isEmpty) {
      _notice('Сервер или тестовый доступ не настроены — статус не изменён');
      return;
    }
    if (value && _services.isEmpty) {
      _notice('Выберите хотя бы одну услугу');
      return;
    }
    final repository = DevJibekApiRepository(
      baseUrl: _apiUrl,
      devUserIdProvider: () async => _devUserId,
    );
    setState(() => _loadingOrders = true);
    try {
      await repository.updateDriverPresence(
        isOnline: value,
        services: value ? _selectedServices : <JibekServiceType>{},
      );
      if (!mounted) return;
      setState(() {
        _online = value;
        if (!value) {
          _orders = [];
          _activeOrder = null;
        }
      });
      _notice(value
          ? 'Вы на линии. Статус сохранён на сервере.'
          : 'Вы отключились от линии.');
      if (value) await _refreshOrders(manageLoading: false);
    } on JibekApiException catch (error) {
      _notice('Не удалось изменить статус: ${error.message}');
    } catch (_) {
      _notice('Нет связи с сервером. Статус не изменён.');
    } finally {
      repository.close();
      if (mounted) setState(() => _loadingOrders = false);
    }
  }

  Future<void> _refreshOrders({bool manageLoading = true}) async {
    if (_services.isEmpty) { _notice('Выберите хотя бы одну услугу'); return; }
    if (_apiUrl.isEmpty || _devUserId.isEmpty) {
      _notice('Сервер или тестовый доступ не настроены');
      return;
    }
    if (manageLoading) setState(() => _loadingOrders = true);
    final repository = DevJibekApiRepository(baseUrl: _apiUrl, devUserIdProvider: () async => _devUserId);
    try {
      final active = await repository.getActiveDriverOrder();
      if (active != null) {
        if (mounted) {
          setState(() {
            _activeOrder = active;
            _orders = [];
          });
        }
      } else {
        final orders =
            await repository.getAvailableOrders(services: _selectedServices);
        if (mounted) {
          setState(() {
            _activeOrder = null;
            _orders = orders;
          });
        }
      }
    } on JibekApiException catch (e) {
      _notice('Ошибка загрузки: ' + e.message);
    } catch (_) {
      _notice('Нет связи с сервером');
    } finally {
      repository.close();
      if (manageLoading && mounted) setState(() => _loadingOrders = false);
    }
  }

  Widget _orderCard(JibekOrderRequest order) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          color: const Color(0xFFF4F6FA),
          child: Row(children: [
            const Icon(Icons.notifications_active_outlined, color: Color(0xFFB18428), size: 19),
            const SizedBox(width: 8),
            Expanded(child: Text(_serviceLabel(order.service),
                style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF071B45)))),
            if (order.vehicleClass != null)
              Chip(label: Text(order.vehicleClass!), visualDensity: VisualDensity.compact),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Column(children: [
                  const Icon(Icons.radio_button_checked, size: 17, color: Color(0xFF23845A)),
                  Container(width: 2, height: 27, color: const Color(0xFFD6DCE5)),
                  const Icon(Icons.location_on, size: 19, color: Color(0xFFC84D43)),
                ]),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ПОДАЧА', style: TextStyle(fontSize: 9, letterSpacing: .8, color: Color(0xFF7A8796), fontWeight: FontWeight.w800)),
                    Text(order.pickup.address ?? 'Точка на карте',
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 9),
                    const Text('НАЗНАЧЕНИЕ', style: TextStyle(fontSize: 9, letterSpacing: .8, color: Color(0xFF7A8796), fontWeight: FontWeight.w800)),
                    Text(order.destination.address ?? 'Точка на карте',
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                )),
              ]),
              if (order.note != null && order.note!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFFFF7E5), borderRadius: BorderRadius.circular(10)),
                  child: Text('Комментарий: ${order.note!}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF684A1C))),
                ),
              ],
              const SizedBox(height: 13),
              SizedBox(width: double.infinity, child: FilledButton.icon(
                onPressed: () => _acceptOrder(order),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Принять заказ'),
              )),
            ],
          ),
        ),
      ],
    ),
  );

  Future<void> _acceptOrder(JibekOrderRequest order) async {
    final repository = DevJibekApiRepository(baseUrl: _apiUrl, devUserIdProvider: () async => _devUserId);
    try {
      final accepted = await repository.acceptOrder(orderId: order.id);
      if (!mounted) return;
      setState(() {
        _orders.removeWhere((item) => item.id == accepted.id);
        _activeOrder = accepted;
      });
      _notice('Заказ принят');
    } on JibekApiException catch (e) {
      _notice('Не удалось принять: ' + e.message);
      _refreshOrders();
    } catch (_) {
      _notice('Нет связи с сервером');
    } finally {
      repository.close();
    }
  }


  JibekOrderStatus? _nextStatus(JibekOrderStatus status) {
    switch (status) {
      case JibekOrderStatus.accepted:
        return JibekOrderStatus.driverArriving;
      case JibekOrderStatus.driverArriving:
        return JibekOrderStatus.inProgress;
      case JibekOrderStatus.inProgress:
        return JibekOrderStatus.completed;
      default:
        return null;
    }
  }

  String _serviceLabel(JibekServiceType service) {
    switch (service) {
      case JibekServiceType.cityTaxi:
        return 'Городское такси';
      case JibekServiceType.intercity:
        return 'Межгород';
      case JibekServiceType.parcel:
        return 'Доставка посылки';
      case JibekServiceType.towTruck:
        return 'Эвакуатор';
      case JibekServiceType.mobileTire:
        return 'Выездной шиномонтаж';
    }
  }

  String _statusLabel(JibekOrderStatus status) {
    switch (status) {
      case JibekOrderStatus.accepted: return 'Заказ принят';
      case JibekOrderStatus.driverArriving: return 'Водитель едет к пассажиру';
      case JibekOrderStatus.inProgress: return 'Поездка началась';
      case JibekOrderStatus.completed: return 'Поездка завершена';
      default: return status.name;
    }
  }

  Widget _activeOrderCard(JibekOrderRequest order) {
    final next = _nextStatus(order.status);
    return Card(
      color: const Color(0xFFFFF3D4),
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('МОЙ ЗАКАЗ', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1D7A50))),
          const SizedBox(height: 6),
          Text(_serviceLabel(order.service),
              style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF071B45))),
          const SizedBox(height: 4),
          Text(_statusLabel(order.status), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          Text('Откуда: ' + (order.pickup.address ?? 'Точка на карте')),
          Text('Куда: ' + (order.destination.address ?? 'Точка на карте')),
          if (order.vehicleClass != null) Text('Класс: ' + order.vehicleClass!),
          if (order.note != null && order.note!.trim().isNotEmpty)
            Text('Комментарий: ' + order.note!,
                style: const TextStyle(color: Color(0xFF687386))),
          if (next != null) ...[
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: () => _advanceOrder(order, next),
              child: Text(next == JibekOrderStatus.driverArriving ? 'Я выехал к пассажиру' : next == JibekOrderStatus.inProgress ? 'Начать поездку' : 'Завершить поездку'),
            )),
          ],
        ]),
      ),
    );
  }

  Future<void> _advanceOrder(JibekOrderRequest order, JibekOrderStatus status) async {
    final repository = DevJibekApiRepository(baseUrl: _apiUrl, devUserIdProvider: () async => _devUserId);
    try {
      final updated = await repository.updateOrderStatus(orderId: order.id, status: status);
      if (!mounted) return;
      setState(() {
        _activeOrder = updated.status == JibekOrderStatus.completed ? null : updated;
      });
      _notice(updated.status == JibekOrderStatus.completed ? 'Заказ завершён' : _statusLabel(updated.status));
      if (_online && updated.status == JibekOrderStatus.completed) _refreshOrders();
    } on JibekApiException catch (e) {
      _notice('Не удалось обновить статус: ' + e.message);
    } catch (_) {
      _notice('Нет связи с сервером');
    } finally {
      repository.close();
    }
  }

  Widget _serviceChip(String label, IconData icon) {
    final selected = _services.contains(label);
    return FilterChip(
      selected: selected,
      showCheckmark: false,
      avatar: Icon(icon, size: 18, color: selected ? const Color(0xFF071B45) : const Color(0xFF687386)),
      label: Text(label),
      onSelected: (value) {
        setState(() {
          if (value) {
            _services.add(label);
          } else {
            _services.remove(label);
          }
        });
        if (_online) {
          if (_services.isEmpty) {
            _setOnline(false);
            _notice('Выберите хотя бы одну услугу — вы отключены от линии');
          } else {
            _setOnline(true);
          }
        }
      },
      selectedColor: const Color(0xFFFFE7A0),
      side: BorderSide(color: selected ? const Color(0xFFD6A84F) : const Color(0xFFE1E6EC)),
    );
  }
}
