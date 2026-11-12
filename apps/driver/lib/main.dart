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
  String _service = 'Такси';

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
              width: 48,
              height: 48,
              child: const Icon(Icons.local_taxi_rounded,
                  color: Color(0xFF168C8C), size: 38),
            ),
          ];

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: _shymkent, initialZoom: 13),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'kz.jibekzholy.driver',
              ),
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
                        Text('КАБИНЕТ ВОДИТЕЛЯ', style: TextStyle(color: Color(0xFFE3BD70), fontSize: 9, letterSpacing: .8)),
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
                      onPressed: _loadingLocation ? null : _locateDriver,
                      icon: _loadingLocation
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.my_location_rounded, color: Color(0xFF10243A)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: .48,
            minChildSize: .38,
            maxChildSize: .78,
            snap: true,
            snapSizes: const [.48, .78],
            builder: (context, controller) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0, -4))],
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: [
                  Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: const Color(0xFFD9DEE5), borderRadius: BorderRadius.circular(8)))),
                  const SizedBox(height: 17),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Статус водителя', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: Color(0xFF10243A))),
                            const SizedBox(height: 4),
                            Text(_online ? 'Вы включили режим на линии' : 'Вы сейчас не принимаете заявки',
                                style: const TextStyle(color: Color(0xFF687386), fontSize: 13)),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: _online,
                        activeColor: const Color(0xFF168C8C),
                        onChanged: (value) {
                          setState(() => _online = value);
                          _notice(value
                              ? 'Режим на линии включён только на этом устройстве. Сервер заказов ещё не подключён.'
                              : 'Вы выключили режим на линии');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _online ? const Color(0xFFEAF5F1) : const Color(0xFFF1F3F6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(_online ? Icons.wifi_tethering_rounded : Icons.pause_circle_outline,
                            color: _online ? const Color(0xFF16834A) : const Color(0xFF687386), size: 28),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            _online ? 'Ожидание подключения к системе заказов' : 'Включите режим, когда будете готовы работать',
                            style: const TextStyle(fontWeight: FontWeight.w700, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Какие заказы готовы выполнять?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
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
                  const SizedBox(height: 18),
                  const Text('Новые заказы', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19, color: Color(0xFF10243A))),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 23, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE4E9EF)),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.inbox_outlined, size: 36, color: Color(0xFF9AA5B2)),
                        SizedBox(height: 8),
                        Text('Пока нет заявок', style: TextStyle(fontWeight: FontWeight.w800)),
                        SizedBox(height: 4),
                        Text('Реальные заявки появятся после подключения сервера и регистрации водителей.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF687386), fontSize: 12, height: 1.4)),
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

  Widget _serviceChip(String label, IconData icon) {
    final selected = _service == label;
    return FilterChip(
      selected: selected,
      showCheckmark: false,
      avatar: Icon(icon, size: 18, color: selected ? const Color(0xFF10243A) : const Color(0xFF687386)),
      label: Text(label),
      onSelected: (_) => setState(() => _service = label),
      selectedColor: const Color(0xFFE8D5AC),
      side: BorderSide(color: selected ? const Color(0xFFD6A84F) : const Color(0xFFE1E6EC)),
    );
  }
}
