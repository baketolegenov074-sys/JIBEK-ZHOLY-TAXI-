// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jibek_shared/jibek_shared.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'passenger_home_page.dart';

void main() => runApp(const JibekPassengerApp());

class JibekPassengerApp extends StatelessWidget {
  const JibekPassengerApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Bake Taxi',
        debugShowCheckedModeBanner: false,
        theme: JibekTheme.light(),
        home: const PassengerHomePage(),
      );
}

class PlaceResult {
  const PlaceResult(this.title, this.point);
  final String title;
  final LatLng point;
}

class PassengerMapPage extends StatefulWidget {
  const PassengerMapPage({super.key, this.initialService = JibekServiceType.cityTaxi, this.initialDestination, this.initialNote});

  final JibekServiceType initialService;
  final String? initialDestination;
  final String? initialNote;

  @override
  State<PassengerMapPage> createState() => _PassengerMapPageState();
}

class _PassengerMapPageState extends State<PassengerMapPage> {
  final MapController _mapController = MapController();
  final TextEditingController _fromController =
      TextEditingController(text: 'Моё местоположение');
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _stopController = TextEditingController();
  bool _addStop = false;
  String _paymentMethod = 'Наличные';
  bool _childSeat = false;
  bool _needMovers = false;
  final LatLng _shymkent = const LatLng(42.3154, 69.5869);

  LatLng? _fromPoint;
  LatLng? _toPoint;
  List<LatLng> _route = [];
  String _class = 'Эконом';
  late JibekServiceType _service;
  String? _distanceLabel;
  String? _durationLabel;
  bool _locating = false;
  bool _searching = false;
  bool _sendingOrder = false;
  bool _refreshingOrder = false;
  bool _cancellingOrder = false;
  JibekOrderRequest? _createdOrder;
  static const _apiUrl = String.fromEnvironment('JIBEK_API_URL');
  static const _devUserId = String.fromEnvironment('JIBEK_DEV_USER_ID');

  @override
  void initState() {
    super.initState();
    _service = widget.initialService;
    final initialNote = widget.initialNote?.trim();
    if (initialNote != null && initialNote.isNotEmpty) {
      _noteController.text = initialNote;
    }
    final destination = widget.initialDestination?.trim();
    if (destination != null && destination.isNotEmpty) {
      _toController.text = destination;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchDestination();
      });
    }
    _restoreSavedOrder();
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _noteController.dispose();
    _stopController.dispose();
    super.dispose();
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _findMe() async {
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _message('Включите геолокацию на телефоне');
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _message('Разрешите доступ к местоположению в настройках телефона');
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      final point = LatLng(position.latitude, position.longitude);
      setState(() {
        _fromPoint = point;
        _fromController.text = 'Моё местоположение';
      });
      _mapController.move(point, 15);
      if (_toPoint != null) await _buildRoute();
    } catch (_) {
      _message('Не удалось определить местоположение');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<PlaceResult?> _geocode(String query) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'jsonv2',
      'limit': '1',
      'countrycodes': 'kz',
      'accept-language': 'ru',
    });
    final response = await http.get(uri, headers: {
      'User-Agent': 'JibekZholyPassenger/1.0 (mobile app)',
      'Accept': 'application/json',
    });
    if (response.statusCode != 200) {
      throw Exception('Сервис поиска адресов временно недоступен');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    if (data.isEmpty) return null;
    final item = data.first as Map<String, dynamic>;
    final lat = double.tryParse(item['lat']?.toString() ?? '');
    final lon = double.tryParse(item['lon']?.toString() ?? '');
    if (lat == null || lon == null) return null;
    return PlaceResult(
      item['display_name']?.toString() ?? query,
      LatLng(lat, lon),
    );
  }

  Future<void> _searchDestination() async {
    final query = _toController.text.trim();
    if (query.isEmpty) {
      _message('Введите адрес или название места');
      return;
    }
    setState(() => _searching = true);
    try {
      final result = await _geocode('$query, Казахстан');
      if (result == null) {
        _message('Адрес не найден. Уточните название или улицу.');
        return;
      }
      setState(() {
        _toPoint = result.point;
        _toController.text = result.title;
        _route = [];
        _distanceLabel = null;
        _durationLabel = null;
      });
      _mapController.move(result.point, 14);
      if (_fromPoint != null) await _buildRoute();
    } catch (e) {
      _message('Ошибка поиска адреса: $e');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _buildRoute() async {
    final start = _fromPoint;
    final end = _toPoint;
    if (start == null || end == null) {
      _message('Сначала укажите точку отправления и назначения');
      return;
    }
    setState(() => _searching = true);
    try {
      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${start.longitude},${start.latitude};'
        '${end.longitude},${end.latitude}'
        '?overview=full&geometries=geojson',
      );
      final response = await http.get(uri, headers: {
        'User-Agent': 'JibekZholyPassenger/1.0',
      });
      if (response.statusCode != 200) throw Exception('Ошибка построения маршрута');
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final routes = json['routes'] as List<dynamic>? ?? [];
      if (routes.isEmpty) {
        _message('Маршрут не найден');
        return;
      }
      final route = routes.first as Map<String, dynamic>;
      final geometry = route['geometry'] as Map<String, dynamic>;
      final coordinates = geometry['coordinates'] as List<dynamic>;
      if (coordinates.length < 2) {
        _message('Маршрут получен без координат. Попробуйте выбрать адрес ещё раз.');
        return;
      }
      final points = coordinates.map((pair) {
        final p = pair as List<dynamic>;
        return LatLng((p[1] as num).toDouble(), (p[0] as num).toDouble());
      }).toList();
      final meters = (route['distance'] as num).toDouble();
      final seconds = (route['duration'] as num).toDouble();
      setState(() {
        _route = points;
        _distanceLabel = meters >= 1000
            ? '${(meters / 1000).toStringAsFixed(1)} км'
            : '${meters.round()} м';
        _durationLabel = '${(seconds / 60).ceil()} мин';
      });
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.fromLTRB(42, 100, 42, 330),
      ));
    } catch (e) {
      _message('Не удалось построить маршрут: $e');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _selectMapPoint(TapPosition tapPosition, LatLng point) {
    setState(() {
      _toPoint = point;
      _toController.text =
          '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
      _route = [];
      _distanceLabel = null;
      _durationLabel = null;
    });
    if (_fromPoint != null) _buildRoute();
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      if (_fromPoint != null)
        Marker(
          point: _fromPoint!,
          width: 42,
          height: 42,
          child: const Icon(Icons.my_location, color: Color(0xFF10243A), size: 32),
        ),
      if (_toPoint != null)
        Marker(
          point: _toPoint!,
          width: 46,
          height: 46,
          child: const Icon(Icons.location_on, color: Color(0xFFC84D43), size: 42),
        ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _shymkent,
              initialZoom: 13,
              onTap: _selectMapPoint,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'kz.jibekzholy.passenger',
              ),
              if (_route.isNotEmpty)
                PolylineLayer(polylines: [
                  Polyline(
                    points: _route,
                    strokeWidth: 5,
                    color: const Color(0xFF10243A),
                    borderStrokeWidth: 1.5,
                    borderColor: Colors.white,
                  ),
                ]),
              MarkerLayer(markers: markers),
              const RichAttributionWidget(
                attributions: [TextSourceAttribution('© OpenStreetMap contributors')],
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10243A),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bake Taxi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        Text('ТАКСИ • ДОСТАВКА • ПОМОЩЬ', style: TextStyle(color: Color(0xFFE3BD70), fontSize: 9, letterSpacing: .7)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 3,
                    child: IconButton(
                      tooltip: 'Моё местоположение',
                      onPressed: _locating ? null : _findMe,
                      icon: _locating
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.my_location_rounded, color: Color(0xFF10243A)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: .47,
            minChildSize: .36,
            maxChildSize: .78,
            snap: true,
            snapSizes: const [.47, .78],
            builder: (context, scrollController) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0, -4))],
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: const Color(0xFFD9DEE5), borderRadius: BorderRadius.circular(8)))),
                  const SizedBox(height: 16),
                  const Text('Куда поедем?', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: Color(0xFF10243A))),
                  const SizedBox(height: 14),
                  _placeField(Icons.radio_button_checked, 'Откуда', _fromController, onSubmitted: (_) => _searchFrom(), onChanged: (_) { setState(() { _fromPoint = null; _route = []; _distanceLabel = null; _durationLabel = null; }); }),
                  const SizedBox(height: 9),
                  _placeField(Icons.location_on_rounded, 'Куда', _toController, onSubmitted: (_) => _searchDestination(), onChanged: (_) { setState(() { _toPoint = null; _route = []; _distanceLabel = null; _durationLabel = null; }); }),
                  Align(alignment: Alignment.centerRight, child: TextButton.icon(
                    onPressed: () => setState(() => _addStop = !_addStop),
                    icon: Icon(_addStop ? Icons.remove_circle_outline : Icons.add_circle_outline),
                    label: Text(_addStop ? 'Убрать остановку' : 'Добавить остановку'),
                  )),
                  if (_addStop) _placeField(Icons.more_horiz, 'Промежуточная остановка', _stopController, onSubmitted: (_) {}),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _searching ? null : _searchDestination,
                      icon: const Icon(Icons.search),
                      label: const Text('Найти адрес'),
                    ),
                  ),
                  if (_createdOrder != null)
                    Card(
                      color: const Color(0xFFF1F4F7),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Ваша заявка', style: TextStyle(fontWeight: FontWeight.w900)),
                            ]),
                            const SizedBox(height: 6),
                            Text('Номер: ${_createdOrder!.id}'),
                            Text('Статус: ${_statusLabel(_createdOrder!.status)}',
                                style: const TextStyle(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: _refreshingOrder || _cancellingOrder
                                      ? null
                                      : _refreshOrder,
                                  icon: _refreshingOrder
                                      ? const SizedBox(width: 16, height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2))
                                      : const Icon(Icons.refresh),
                                  label: const Text('Обновить статус'),
                                ),
                                if (_canCancelOrder(_createdOrder!.status))
                                  TextButton.icon(
                                    onPressed: _refreshingOrder || _cancellingOrder
                                        ? null
                                        : _cancelOrder,
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    label: const Text('Отменить',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_distanceLabel != null && _durationLabel != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF1F4F7), borderRadius: BorderRadius.circular(14)),
                      child: Row(children: [
                        const Icon(Icons.route, color: Color(0xFF10243A)),
                        const SizedBox(width: 10),
                        Text('$_distanceLabel  •  $_durationLabel', style: const TextStyle(fontWeight: FontWeight.w800)),
                      ]),
                    ),
                  const SizedBox(height: 8),
                  const Text('Категории услуг', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF26384D))),
                  const SizedBox(height: 8),
                  SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
                    _serviceTab('Такси', JibekServiceType.cityTaxi),
                    _serviceTab('Доставка и Грузовой', JibekServiceType.freight),
                    _serviceTab('Спецтехника', JibekServiceType.towTruck),
                    _serviceTab('Межгород', JibekServiceType.intercity),
                  ])),
                  const SizedBox(height: 12),
                  const Text('Что вам нужно?', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF26384D))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      (JibekServiceType.cityTaxi, 'Городское такси'),
                      (JibekServiceType.intercity, 'Межгород'),
                      (JibekServiceType.parcel, 'Доставка / Посылка'),
                      (JibekServiceType.freight, 'Грузовой'),
                      (JibekServiceType.towTruck, 'Эвакуатор'),
                      (JibekServiceType.mobileTire, 'Шиномонтаж'),
                    ].map((item) => ChoiceChip(
                      label: Text(item.$2),
                      selected: _service == item.$1,
                      onSelected: (_) => setState(() => _service = item.$1),
                      selectedColor: const Color(0xFFE9EEF4),
                    )).toList(),
                  ),
                  if (_service == JibekServiceType.cityTaxi) ...[
                    const SizedBox(height: 8),
                    const Text('Класс автомобиля', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF26384D))),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 8,
                    children: ['Эконом', 'Комфорт', 'Бизнес'].map((item) => ChoiceChip(
                      label: Text(item),
                      selected: _class == item,
                      onSelected: (_) => setState(() => _class = item),
                      selectedColor: const Color(0xFFE9EEF4),
                      labelStyle: TextStyle(fontWeight: FontWeight.w700, color: _class == item ? const Color(0xFF10243A) : const Color(0xFF657184)),
                      side: BorderSide(color: _class == item ? const Color(0xFFE3BD70) : const Color(0xFFE1E6EC)),
                    )).toList(),
                  ),
                  ],
                  if (_service == JibekServiceType.cityTaxi) ...[
                    const SizedBox(height: 12),
                    const Text('Выберите тариф', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(height: 8),
                    SizedBox(height: 122, child: ListView(scrollDirection: Axis.horizontal, children: [
                      _tariffCard('Вместе', Icons.people_alt_rounded, 'от 4 мин', 'Цена после маршрута'),
                      _tariffCard('Эконом', Icons.directions_car_rounded, 'от 2 мин', 'Цена после маршрута'),
                      _tariffCard('Комфорт', Icons.airline_seat_recline_extra, 'от 5 мин', 'Цена после маршрута'),
                      _tariffCard('Бизнес', Icons.directions_car_filled, 'от 7 мин', 'Цена после маршрута'),
                    ])),
                  ],
                  if (_service == JibekServiceType.freight || _service == JibekServiceType.parcel || _service == JibekServiceType.towTruck || _service == JibekServiceType.mobileTire) ...[
                    const SizedBox(height: 10),
                    const Text('Выбранная услуга', style: TextStyle(fontWeight: FontWeight.w900)),
                    Wrap(spacing: 8, children: [
                      if (_service == JibekServiceType.parcel) const Chip(label: Text('Посылка')),
                      if (_service == JibekServiceType.freight) const Chip(label: Text('Грузовой')),
                      if (_service == JibekServiceType.towTruck) const Chip(label: Text('Эвакуатор')),
                      if (_service == JibekServiceType.mobileTire) const Chip(label: Text('Шиномонтаж')),
                    ]),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    maxLines: 2,
                    maxLength: 500,
                    decoration: InputDecoration(
                      labelText: _service == JibekServiceType.parcel
                          ? 'Что нужно доставить?'
                           : _service == JibekServiceType.freight
                              ? 'Опишите груз, габариты и адрес доставки'
                              : _service == JibekServiceType.towTruck
                              ? 'Опишите автомобиль и поломку'
                              : _service == JibekServiceType.mobileTire
                                  ? 'Укажите размер колёс и проблему'
                                  : 'Комментарий водителю',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: OutlinedButton.icon(
                      onPressed: () => setState(() => _paymentMethod = _paymentMethod == 'Наличные' ? 'Kaspi' : 'Наличные'),
                      icon: const Icon(Icons.payments_outlined), label: Text(_paymentMethod),
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: OutlinedButton.icon(
                      onPressed: _showPreferences,
                      icon: const Icon(Icons.tune_rounded), label: const Text('Пожелания'),
                    )),
                  ]),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: (_searching || _sendingOrder) ? null : () {
                        if (_toPoint == null) {
                          _searchDestination();
                        } else if (_fromPoint == null) {
                          if (_fromController.text.trim().isNotEmpty &&
                              _fromController.text.trim() != 'Моё местоположение') {
                            _searchFrom();
                          } else {
                            _findMe();
                          }
                        } else if (_route.isEmpty) {
                          _buildRoute();
                        } else {
                          _submitOrder();
                        }
                      },
                      icon: _searching
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.local_taxi_rounded),
                      label: Text((_searching || _sendingOrder) ? 'Подождите...' : (_route.isNotEmpty ? (_service == JibekServiceType.parcel ? 'Заказать доставку' : _service == JibekServiceType.freight ? 'Заказать грузовую машину' : _service == JibekServiceType.towTruck ? 'Вызвать эвакуатор' : _service == JibekServiceType.mobileTire ? 'Вызвать шиномонтаж' : 'Заказать поездку') : 'Продолжить'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE3BD70), foregroundColor: const Color(0xFF10243A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Введите адрес назначения или коснитесь карты. Для построения маршрута разрешите геолокацию.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF7A8796), fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceTab(String label, JibekServiceType service) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label), selected: _service == service,
      selectedColor: const Color(0xFFE5EBF2),
      onSelected: (_) => setState(() => _service = service),
    ),
  );

  Widget _tariffCard(String label, IconData icon, String eta, String price) {
    final selected = _class == label;
    return GestureDetector(
      onTap: () => setState(() => _class = label),
      child: Container(
        width: 142, margin: const EdgeInsets.only(right: 9), padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF0F6) : Colors.white,
          border: Border.all(color: selected ? const Color(0xFFE3BD70) : const Color(0xFFE1E6EC), width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 30, color: const Color(0xFF10243A)),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
          Text(eta, style: const TextStyle(fontSize: 11, color: Color(0xFF687386))),
          Text(price, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Future<void> _showPreferences() async {
    await showModalBottomSheet<void>(
      context: context, isScrollControlled: true,
      builder: (context) => SafeArea(child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Пожелания к заказу', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          TextField(controller: _noteController, maxLines: 2, decoration: const InputDecoration(labelText: 'Комментарий водителю')),
          const SizedBox(height: 8),
          CheckboxListTile(value: _childSeat, onChanged: (v) => setState(() => _childSeat = v ?? false), title: const Text('Детское кресло'), contentPadding: EdgeInsets.zero),
          CheckboxListTile(value: _needMovers, onChanged: (v) => setState(() => _needMovers = v ?? false), title: const Text('Нужны грузчики'), contentPadding: EdgeInsets.zero),
          Align(alignment: Alignment.centerRight, child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Готово'))),
        ]),
      )),
    );
  }

  Future<void> _submitOrder() async {
    final requiresDetails = _service == JibekServiceType.parcel ||
        _service == JibekServiceType.freight ||
        _service == JibekServiceType.towTruck ||
        _service == JibekServiceType.mobileTire;
    if (requiresDetails && _noteController.text.trim().isEmpty) {
      _message(_service == JibekServiceType.parcel
          ? 'Опишите посылку и что нужно доставить'
           : _service == JibekServiceType.freight
              ? 'Опишите груз, габариты и адрес доставки'
              : _service == JibekServiceType.towTruck
              ? 'Укажите автомобиль и характер поломки'
              : 'Укажите размер колёс и проблему');
      return;
    }
    if (_fromPoint == null || _toPoint == null || _route.isEmpty) {
      _message('Сначала постройте маршрут'); return;
    }
    if (_apiUrl.isEmpty || _devUserId.isEmpty) {
      _message('Отправка пока закрыта: сервер и тестовый доступ не настроены'); return;
    }
    setState(() => _sendingOrder = true);
    final repository = DevJibekApiRepository(baseUrl: _apiUrl, devUserIdProvider: () async => _devUserId);
    final orderNote = [
      _noteController.text.trim(),
      if (_childSeat) 'Детское кресло',
      if (_needMovers) 'Нужны грузчики',
      'Оплата: $_paymentMethod',
    ].where((item) => item.isNotEmpty).join('; ');
    try {
      final draft = JibekOrderRequest(
        id: 'local-draft', service: _service,
        pickup: JibekGeoPoint(latitude: _fromPoint!.latitude, longitude: _fromPoint!.longitude, address: _fromController.text),
        destination: JibekGeoPoint(latitude: _toPoint!.latitude, longitude: _toPoint!.longitude, address: _toController.text),
        createdAt: DateTime.now(),
        vehicleClass: _service == JibekServiceType.cityTaxi ? _class : null,
        note: orderNote.isEmpty ? null : orderNote,
      );
      final validation = draft.validate();
      if (validation != null) { _message(validation); return; }
      final created = await repository.createOrder(draft);
      if (!mounted) return;
      setState(() => _createdOrder = created);
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('jibek_passenger_active_order_id', created.id);
      await _saveOrderToHistory(created);
      _message('Заявка создана. Номер: ' + created.id);
    } on JibekApiException catch (e) {
      _message('Не удалось отправить заявку: ' + e.message);
    } catch (_) { _message('Нет связи с сервером. Повторите позже.'); }
    finally { repository.close(); if (mounted) setState(() { _sendingOrder = false; _searching = false; }); }
  }
  Future<void> _restoreSavedOrder() async {
    if (_apiUrl.isEmpty || _devUserId.isEmpty) return;
    try {
      final preferences = await SharedPreferences.getInstance();
      final orderId = preferences.getString('jibek_passenger_active_order_id');
      if (orderId == null || orderId.isEmpty) return;
      final repository = _orderRepository();
      try {
        final order = await repository.getOrder(orderId: orderId);
        if (!mounted) return;
        setState(() => _createdOrder = order);
        await _saveOrderState(order);
      } on JibekApiException catch (error) {
        if (error.statusCode == 404 || error.statusCode == 403) {
          await preferences.remove('jibek_passenger_active_order_id');
        } else {
          _message('Не удалось восстановить заявку: ${error.message}');
        }
      } finally {
        repository.close();
      }
    } catch (_) {
      _message('Не удалось восстановить сохранённую заявку');
    }
  }

  Future<void> _saveOrderToHistory(JibekOrderRequest order) async {
    final preferences = await SharedPreferences.getInstance();
    final history = preferences.getStringList('bake_taxi_order_history') ?? <String>[];
    history.removeWhere((entry) {
      try {
        return (jsonDecode(entry) as Map)['id'] == order.id;
      } catch (_) {
        return false;
      }
    });
    history.insert(0, jsonEncode(order.toJson()));
    await preferences.setStringList(
      'bake_taxi_order_history',
      history.take(20).toList(),
    );
  }

  Future<void> _saveOrderState(JibekOrderRequest order) async {
    await _saveOrderToHistory(order);
    final isTerminal = order.status == JibekOrderStatus.completed ||
        order.status == JibekOrderStatus.cancelled;
    if (!isTerminal) return;
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getString('jibek_passenger_active_order_id') == order.id) {
      await preferences.remove('jibek_passenger_active_order_id');
    }
  }

  String _statusLabel(JibekOrderStatus status) => switch (status) {
        JibekOrderStatus.searching => 'Ищем водителя',
        JibekOrderStatus.accepted => 'Водитель принял заказ',
        JibekOrderStatus.driverArriving => 'Водитель едет к вам',
        JibekOrderStatus.inProgress => 'Поездка началась',
        JibekOrderStatus.completed => 'Поездка завершена',
        JibekOrderStatus.cancelled => 'Заказ отменён',
        JibekOrderStatus.draft => 'Черновик',
      };

  bool _canCancelOrder(JibekOrderStatus status) =>
      status == JibekOrderStatus.searching ||
      status == JibekOrderStatus.accepted ||
      status == JibekOrderStatus.driverArriving;

  DevJibekApiRepository _orderRepository() => DevJibekApiRepository(
        baseUrl: _apiUrl,
        devUserIdProvider: () async => _devUserId,
      );

  Future<void> _refreshOrder() async {
    final order = _createdOrder;
    if (order == null || _apiUrl.isEmpty || _devUserId.isEmpty) return;
    setState(() => _refreshingOrder = true);
    final repository = _orderRepository();
    try {
      final updated = await repository.getOrder(orderId: order.id);
      if (!mounted) return;
      setState(() => _createdOrder = updated);
      await _saveOrderState(updated);
      _message('Статус обновлён: ${_statusLabel(updated.status)}');
    } on JibekApiException catch (e) {
      _message('Не удалось обновить статус: ${e.message}');
    } catch (_) {
      _message('Нет связи с сервером. Повторите позже.');
    } finally {
      repository.close();
      if (mounted) setState(() => _refreshingOrder = false);
    }
  }

  Future<void> _cancelOrder() async {
    final order = _createdOrder;
    if (order == null || !_canCancelOrder(order.status)) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отменить заявку?'),
        content: const Text('Водитель больше не сможет принять этот заказ.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Оставить'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Отменить заказ'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _cancellingOrder = true);
    final repository = _orderRepository();
    try {
      final updated = await repository.updateOrderStatus(
        orderId: order.id,
        status: JibekOrderStatus.cancelled,
      );
      if (!mounted) return;
      setState(() => _createdOrder = updated);
      await _saveOrderState(updated);
      _message('Заявка отменена');
    } on JibekApiException catch (e) {
      _message('Не удалось отменить заявку: ${e.message}');
    } catch (_) {
      _message('Нет связи с сервером. Повторите позже.');
    } finally {
      repository.close();
      if (mounted) setState(() => _cancellingOrder = false);
    }
  }

  Future<void> _searchFrom() async {
    final query = _fromController.text.trim();
    if (query.isEmpty || query == 'Моё местоположение') {
      await _findMe();
      return;
    }
    setState(() => _searching = true);
    try {
      final result = await _geocode('$query, Шымкент, Казахстан');
      if (result == null) {
        _message('Адрес отправления не найден');
        return;
      }
      setState(() => _fromPoint = result.point);
      _mapController.move(result.point, 14);
      if (_toPoint != null) await _buildRoute();
    } catch (e) {
      _message('Ошибка поиска адреса: $e');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Widget _placeField(
    IconData icon,
    String hint,
    TextEditingController controller, {
    required ValueChanged<String> onSubmitted,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF10243A)),
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
      ),
    );
  }
}
