// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jibek_shared/jibek_shared.dart';
import 'package:latlong2/latlong.dart';
import 'permissions/startup_permissions.dart';
import 'driver_profile_page.dart';
import 'driver_search_settings.dart';

void main() => runApp(const JibekDriverApp());

class JibekDriverApp extends StatelessWidget {
  const JibekDriverApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Bake Taxi Водитель',
        debugShowCheckedModeBanner: false,
        theme: JibekTheme.light(),
        home: const DriverAppShell(),
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
  final Set<String> _services = {'Такси', 'Межгород', 'Посылки', 'Грузовой', 'Эвакуатор', 'Шиномонтаж'};
  List<JibekOrderRequest> _orders = [];
  JibekOrderRequest? _activeOrder;
  bool _loadingOrders = false;
  static const _apiUrl = String.fromEnvironment('JIBEK_API_URL');
  static const _devUserId = String.fromEnvironment('JIBEK_DEV_USER_ID');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await requestBakeTaxiPermissions();
      if (mounted) await _locateDriver();
    });
  }

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

  @override
  void dispose() {
    _ordersTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _notice(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  bool _alternateMap = false;
  Timer? _ordersTimer;

  @override
  Widget build(BuildContext context) {
    final markers = _driverPoint == null
        ? <Marker>[]
        : [
            Marker(
              point: _driverPoint!,
              width: 54,
              height: 54,
              child: const Icon(Icons.navigation_rounded,
                  color: Color(0xFF168C8C), size: 43),
            ),
          ];

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(initialCenter: _shymkent, initialZoom: 13),
              children: [
                TileLayer(
                  urlTemplate: _alternateMap
                      ? 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png'
                      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: _alternateMap ? const ['a', 'b', 'c'] : const [],
                  userAgentPackageName: 'kz.jibekzholy.driverapp',
                ),
                MarkerLayer(markers: markers),
                const RichAttributionWidget(
                  attributions: [TextSourceAttribution('© OpenStreetMap contributors')],
                ),
              ],
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, right: 14),
                child: Column(
                  children: [
                    _mapAction(Icons.tune_rounded, 'Настройки поиска',
                        () => showDriverSearchSettings(context)),
                    const SizedBox(height: 12),
                    _mapAction(Icons.add, 'Приблизить',
                        () => _mapController.move(_mapController.camera.center,
                            (_mapController.camera.zoom + 1).clamp(3, 19).toDouble())),
                    const SizedBox(height: 8),
                    _mapAction(Icons.remove, 'Отдалить',
                        () => _mapController.move(_mapController.camera.center,
                            (_mapController.camera.zoom - 1).clamp(3, 19).toDouble())),
                    const SizedBox(height: 8),
                    _mapAction(Icons.layers_outlined, 'Слои карты',
                        () => setState(() => _alternateMap = !_alternateMap)),
                    const SizedBox(height: 8),
                    _mapAction(
                      _loadingLocation ? Icons.hourglass_top : Icons.my_location,
                      'Моё местоположение',
                      _loadingLocation ? () {} : _locateDriver,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 285),
                child: FloatingActionButton.small(
                  heroTag: 'driver-address-search',
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF10243A),
                  onPressed: _showAddressSearch,
                  child: const Icon(Icons.search_rounded),
                ),
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: .43,
            minChildSize: .30,
            maxChildSize: .78,
            snap: true,
            snapSizes: const [.43, .78],
            builder: (context, controller) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0, -4))],
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(18, 11, 18, 105),
                children: [
                  Center(child: Container(width: 42, height: 4,
                    decoration: BoxDecoration(color: const Color(0xFFD9DEE5), borderRadius: BorderRadius.circular(8)))),
                  const SizedBox(height: 15),
                  Row(children: [
                    Expanded(child: _dashboardMetric(
                      icon: Icons.bolt_rounded, title: 'Приоритет', value: '+7',
                      tint: const Color(0xFFB58A16))),
                    const SizedBox(width: 10),
                    Expanded(child: _dashboardMetric(
                      icon: Icons.account_balance_wallet_outlined, title: 'Заработок',
                      value: '0 KZT', subtitle: '0 заказов', tint: const Color(0xFF16834A))),
                  ]),
                  const SizedBox(height: 16),
                  const Text('Цели и бонусы', style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF10243A))),
                  const SizedBox(height: 9),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFFFFF8DF),
                      borderRadius: BorderRadius.circular(17)),
                    child: Row(children: [
                      const Icon(Icons.workspace_premium_outlined, color: Color(0xFFB58A16), size: 28),
                      const SizedBox(width: 11),
                      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Бонусы и цели смены', style: TextStyle(fontWeight: FontWeight.w800)),
                        SizedBox(height: 3),
                        Text('Подключите доступные тарифы и выполняйте заказы',
                          style: TextStyle(fontSize: 12, color: Color(0xFF687386))),
                      ])),
                      const Icon(Icons.chevron_right_rounded, color: Color(0xFF687386)),
                    ]),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 58,
                    child: FilledButton(
                      onPressed: _loadingOrders ? null : () => _setOnline(!_online),
                      style: FilledButton.styleFrom(
                        backgroundColor: _online ? const Color(0xFF16834A) : const Color(0xFFFFD400),
                        foregroundColor: const Color(0xFF10243A),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(_loadingOrders ? 'Подождите…' : (_online ? 'На линии' : 'Офлайн / Выйти на линию'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                        const SizedBox(width: 9),
                        Icon(_online ? Icons.check_circle_rounded : Icons.arrow_forward_rounded),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 13),
                  if (_online) ...[
                    Row(children: [
                      const Expanded(child: Text('Новые заказы', style: TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF10243A)))),
                      IconButton(onPressed: _loadingOrders ? null : _refreshOrders,
                        icon: const Icon(Icons.refresh_rounded)),
                    ]),
                    if (_loadingOrders) const Center(child: CircularProgressIndicator()),
                    if (_activeOrder != null) _activeOrderCard(_activeOrder!),
                    ..._orders.map(_orderCard),
                    if (_orders.isEmpty && !_loadingOrders)
                      const Padding(padding: EdgeInsets.all(12),
                        child: Text('Свободный эфир: пока нет доступных заказов', textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF687386)))),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapAction(IconData icon, String tooltip, VoidCallback onPressed) =>
      Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 4,
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon, color: const Color(0xFF10243A)),
        ),
      );

  Widget _dashboardMetric({required IconData icon, required String title,
      required String value, String? subtitle, required Color tint}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(color: const Color(0xFFF4F5F7),
          borderRadius: BorderRadius.circular(17)),
        child: Row(children: [
          Icon(icon, color: tint, size: 25),
          const SizedBox(width: 9),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF687386))),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
              color: Color(0xFF10243A))),
            if (subtitle != null) Text(subtitle,
              style: const TextStyle(fontSize: 10, color: Color(0xFF687386))),
          ])),
        ]),
      );

  Future<void> _showAddressSearch() async {
    final controller = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(
                color: const Color(0xFFD9DEE5), borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 18),
              const Text('Поиск заказов по адресу', style: TextStyle(
                fontSize: 21, fontWeight: FontWeight.w900, color: Color(0xFF10243A))),
              const SizedBox(height: 13),
              TextField(controller: controller, textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Адрес или место',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: TextButton(onPressed: () => Navigator.pop(sheetContext),
                    child: const Text('Карта')),
                  filled: true, fillColor: const Color(0xFFF3F5F7),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none))),
              const SizedBox(height: 12),
              const Text('Быстрые режимы', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 9),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _searchModeChip('Домой', Icons.home_rounded),
                _searchModeChip('По делам', Icons.work_outline_rounded),
                _searchModeChip('Мой район', Icons.location_city_rounded),
                _searchModeChip('Межгород', Icons.route_rounded),
              ]),
              const SizedBox(height: 12),
              const Text('Сохранённые адреса', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 7),
              const ListTile(dense: true, contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.home_outlined), title: Text('Дом'), subtitle: Text('Адрес не добавлен')),
              const ListTile(dense: true, contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.work_outline), title: Text('Работа'), subtitle: Text('Адрес не добавлен')),
            ]),
        ),
      ),
    );
    controller.dispose();
  }

  Widget _searchModeChip(String label, IconData icon) => ActionChip(
    avatar: Icon(icon, size: 18, color: const Color(0xFF10243A)),
    label: Text(label),
    onPressed: () => _notice('Режим «$label» будет применён после настройки адреса'),
  );



  Set<JibekServiceType> get _selectedServices {
    const mapping = {
      'Такси': JibekServiceType.cityTaxi,
      'Межгород': JibekServiceType.intercity,
      'Посылки': JibekServiceType.parcel,
      'Грузовой': JibekServiceType.freight,
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
          _ordersTimer?.cancel();
        } else {
          _ordersTimer?.cancel();
          _ordersTimer = Timer.periodic(const Duration(seconds: 8), (_) {
            if (mounted && _online && !_loadingOrders && _activeOrder == null) _refreshOrders();
          });
        }
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
        final driverPoint = _driverPoint;
        if (driverPoint != null) {
          orders.sort((a, b) => Geolocator.distanceBetween(
            driverPoint.latitude, driverPoint.longitude,
            a.pickup.latitude, a.pickup.longitude,
          ).compareTo(Geolocator.distanceBetween(
            driverPoint.latitude, driverPoint.longitude,
            b.pickup.latitude, b.pickup.longitude,
          )));
        }
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
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(_serviceLabel(order.service), style: const TextStyle(fontWeight: FontWeight.w900))),
          if (order.isBoosted) Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFFFE1B8), borderRadius: BorderRadius.circular(20)), child: const Text('🔥 Повышенная цена', style: TextStyle(color: Color(0xFFB74700), fontWeight: FontWeight.w900, fontSize: 11))),
        ]),
        const SizedBox(height: 7),
        Text('${order.priceKzt} ₸', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF16834A))),
        Text('До подачи: ${_pickupDistance(order)}', style: const TextStyle(color: Color(0xFF687386), fontWeight: FontWeight.w700)),
        Text('Откуда: ' + (order.pickup.address ?? 'Точка на карте')),
        Text('Куда: ' + (order.destination.address ?? 'Точка на карте')),
        if (order.vehicleClass != null) Text('Класс: ' + order.vehicleClass!),
        if (order.note != null && order.note!.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text('Комментарий: ' + order.note!,
              style: const TextStyle(color: Color(0xFF687386))),
        ],
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: FilledButton(
          onPressed: () => _acceptOrder(order),
          child: const Text('Принять заказ'),
        )),
      ]),
    ),
  );

  String _pickupDistance(JibekOrderRequest order) {
    final point = _driverPoint;
    if (point == null) return 'геолокация недоступна';
    final meters = Geolocator.distanceBetween(point.latitude, point.longitude, order.pickup.latitude, order.pickup.longitude);
    return meters >= 1000 ? '${(meters / 1000).toStringAsFixed(1)} км' : '${meters.round()} м';
  }

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
      case JibekServiceType.freight:
        return 'Грузовой';
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
      color: const Color(0xFFEAF5F1),
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('МОЙ ЗАКАЗ', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF16834A))),
          const SizedBox(height: 6),
          Text(_serviceLabel(order.service),
              style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF10243A))),
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
      avatar: Icon(icon, size: 18, color: selected ? const Color(0xFF10243A) : const Color(0xFF687386)),
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
      selectedColor: const Color(0xFFE8D5AC),
      side: BorderSide(color: selected ? const Color(0xFFD6A84F) : const Color(0xFFE1E6EC)),
    );
  }
}


class DriverAppShell extends StatefulWidget {
  const DriverAppShell({super.key});
  @override
  State<DriverAppShell> createState() => _DriverAppShellState();
}

class _DriverAppShellState extends State<DriverAppShell> {
  int _tab = 0;

  Widget _page() {
    switch (_tab) {
      case 0:
        return const DriverMapPage();
      case 1:
        return const DriverSectionPage(
          title: 'Межгород',
          subtitle: 'Заказы между городами будут отображаться здесь',
          icon: Icons.route_rounded,
          detail: 'Включите приём заказов и выберите тариф «Межгород» в настройках поиска.',
        );
      case 2:
        return const DriverSectionPage(
          title: 'Деньги',
          subtitle: 'Заработок и выплаты',
          icon: Icons.account_balance_wallet_rounded,
          detail: 'Здесь будет история заработка за смены и информация о выплатах.',
        );
      case 3:
        return const DriverSectionPage(
          title: 'Чаты',
          subtitle: 'Сообщения',
          icon: Icons.chat_bubble_rounded,
          detail: 'Новые сообщения по заказам будут появляться здесь.',
        );
      default:
        return const DriverProfilePage();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: _page(),
    bottomNavigationBar: NavigationBar(
      height: 68,
      selectedIndex: _tab,
      onDestinationSelected: (index) => setState(() => _tab = index),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Заказы'),
        NavigationDestination(icon: Icon(Icons.route_outlined), selectedIcon: Icon(Icons.route_rounded), label: 'Межгород'),
        NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Деньги'),
        NavigationDestination(icon: Icon(Icons.chat_bubble_outline_rounded), selectedIcon: Icon(Icons.chat_bubble_rounded), label: 'Чаты'),
        NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Профиль'),
      ],
    ),
  );
}

class DriverSectionPage extends StatelessWidget {
  const DriverSectionPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.detail,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String detail;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F6F8),
    appBar: AppBar(
      title: Text(title),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF10243A),
      elevation: 0,
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: const Color(0xFFB58A16)),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w900,
                color: Color(0xFF10243A))),
              const SizedBox(height: 8),
              Text(subtitle, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15,
                  fontWeight: FontWeight.w700, color: Color(0xFF344252))),
              const SizedBox(height: 10),
              Text(detail, textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF687386), height: 1.4)),
            ],
          ),
        ),
      ),
    ),
  );
}
