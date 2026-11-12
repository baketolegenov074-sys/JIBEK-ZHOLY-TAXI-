// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jibek_shared/jibek_shared.dart';
import 'package:latlong2/latlong.dart';

void main() => runApp(const JibekPassengerApp());

class JibekPassengerApp extends StatelessWidget {
  const JibekPassengerApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'ЖІБЕК ЖОЛЫ',
        debugShowCheckedModeBanner: false,
        theme: JibekTheme.light(),
        home: const PassengerMapPage(),
      );
}

class PlaceResult {
  const PlaceResult(this.title, this.point);
  final String title;
  final LatLng point;
}

class PassengerMapPage extends StatefulWidget {
  const PassengerMapPage({super.key});

  @override
  State<PassengerMapPage> createState() => _PassengerMapPageState();
}

class _PassengerMapPageState extends State<PassengerMapPage> {
  final MapController _mapController = MapController();
  final TextEditingController _fromController =
      TextEditingController(text: 'Моё местоположение');
  final TextEditingController _toController = TextEditingController();
  final LatLng _shymkent = const LatLng(42.3154, 69.5869);

  LatLng? _fromPoint;
  LatLng? _toPoint;
  List<LatLng> _route = [];
  String _class = 'Эконом';
  String? _distanceLabel;
  String? _durationLabel;
  bool _locating = false;
  bool _searching = false;
  bool _sendingOrder = false;
  JibekOrderRequest? _createdOrder;
  static const _apiUrl = String.fromEnvironment('JIBEK_API_URL');
  static const _devUserId = String.fromEnvironment('JIBEK_DEV_USER_ID');

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
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
      final result = await _geocode('$query, Шымкент, Казахстан');
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
          child: const Icon(Icons.my_location, color: Color(0xFF168C8C), size: 32),
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
                    color: const Color(0xFF168C8C),
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
                        Text('ЖІБЕК ЖОЛЫ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
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
                  _placeField(Icons.radio_button_checked, 'Откуда', _fromController, onSubmitted: (_) => _searchFrom()),
                  const SizedBox(height: 9),
                  _placeField(Icons.location_on_rounded, 'Куда', _toController, onSubmitted: (_) => _searchDestination()),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _searching ? null : _searchDestination,
                      icon: const Icon(Icons.search),
                      label: const Text('Найти адрес'),
                    ),
                  ),
                  if (_createdOrder != null)\n                    ListTile(leading: const Icon(Icons.check_circle, color: Colors.green), title: const Text('Заявка отправлена'), subtitle: Text('Статус: ' + _createdOrder!.status.name)),\n                  if (_distanceLabel != null && _durationLabel != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFEAF5F3), borderRadius: BorderRadius.circular(14)),
                      child: Row(children: [
                        const Icon(Icons.route, color: Color(0xFF168C8C)),
                        const SizedBox(width: 10),
                        Text('$_distanceLabel  •  $_durationLabel', style: const TextStyle(fontWeight: FontWeight.w800)),
                      ]),
                    ),
                  const SizedBox(height: 8),
                  const Text('Класс автомобиля', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF26384D))),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 8,
                    children: ['Эконом', 'Комфорт', 'Бизнес'].map((item) => ChoiceChip(
                      label: Text(item),
                      selected: _class == item,
                      onSelected: (_) => setState(() => _class = item),
                      selectedColor: const Color(0xFFE8D5AC),
                      labelStyle: TextStyle(fontWeight: FontWeight.w700, color: _class == item ? const Color(0xFF10243A) : const Color(0xFF657184)),
                      side: BorderSide(color: _class == item ? const Color(0xFFD6A84F) : const Color(0xFFE1E6EC)),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: (_searching || _sendingOrder) ? null : () {
                        if (_toPoint == null) {
                          _searchDestination();
                        } else if (_fromPoint == null) {
                          _findMe();
                        } else if (_route.isEmpty) {
                          _buildRoute();
                        } else {
                          _submitOrder();
                        }
                      },
                      icon: _searching
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.local_taxi_rounded),
                      label: Text((_searching || _sendingOrder) ? 'Подождите...' : (_route.isNotEmpty ? 'Заказать такси' : 'Продолжить'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10243A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
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

  Future<void> _submitOrder() async {
    if (_fromPoint == null || _toPoint == null || _route.isEmpty) {
      _message('Сначала постройте маршрут'); return;
    }
    if (_apiUrl.isEmpty || _devUserId.isEmpty) {
      _message('Отправка пока закрыта: сервер и тестовый доступ не настроены'); return;
    }
    setState(() => _sendingOrder = true);
    final repository = DevJibekApiRepository(baseUrl: _apiUrl, devUserIdProvider: () async => _devUserId);
    try {
      final draft = JibekOrderRequest(
        id: 'local-draft', service: JibekServiceType.cityTaxi,
        pickup: JibekGeoPoint(latitude: _fromPoint!.latitude, longitude: _fromPoint!.longitude, address: _fromController.text),
        destination: JibekGeoPoint(latitude: _toPoint!.latitude, longitude: _toPoint!.longitude, address: _toController.text),
        createdAt: DateTime.now(), vehicleClass: _class,
      );
      final validation = draft.validate();
      if (validation != null) { _message(validation); return; }
      final created = await repository.createOrder(draft);
      if (!mounted) return;
      setState(() => _createdOrder = created);
      _message('Заявка создана. Номер: ' + created.id);
    } on JibekApiException catch (e) {
      _message('Не удалось отправить заявку: ' + e.message);
    } catch (_) { _message('Нет связи с сервером. Повторите позже.'); }
    finally { repository.close(); if (mounted) setState(() { _sendingOrder = false; _searching = false; }); }
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
  }) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF168C8C)),
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
      ),
    );
  }
}
