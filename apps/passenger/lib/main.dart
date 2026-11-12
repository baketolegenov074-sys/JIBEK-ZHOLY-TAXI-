import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
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
  LatLng? _userLocation;
  String _class = 'Эконом';
  bool _locating = false;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _findMe() async {
    setState(() => _locating = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
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
        _userLocation = point;
        _fromController.text = 'Моё местоположение';
      });
      _mapController.move(point, 15);
    } catch (_) {
      _message('Не удалось определить местоположение. Попробуйте ещё раз.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value), behavior: SnackBarBehavior.floating),
    );
  }

  void _selectDestination(TapPosition tapPosition, LatLng point) {
    setState(() => _toController.text =
        '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}');
    _message('Точка назначения отмечена на карте');
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      if (_userLocation != null)
        Marker(
          point: _userLocation!,
          width: 46,
          height: 46,
          child: const Icon(Icons.my_location, color: Color(0xFF168C8C), size: 34),
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
              onTap: _selectDestination,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'kz.jibekzholy.passenger',
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
            initialChildSize: .43,
            minChildSize: .34,
            maxChildSize: .78,
            snap: true,
            snapSizes: const [.43, .78],
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
                  Center(
                    child: Container(width: 42, height: 4, decoration: BoxDecoration(color: const Color(0xFFD9DEE5), borderRadius: BorderRadius.circular(8))),
                  ),
                  const SizedBox(height: 16),
                  const Text('Куда поедем?', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: Color(0xFF10243A))),
                  const SizedBox(height: 14),
                  _placeField(Icons.radio_button_checked, 'Откуда', _fromController),
                  const SizedBox(height: 9),
                  _placeField(Icons.location_on_rounded, 'Куда', _toController),
                  const SizedBox(height: 16),
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
                      onPressed: () {
                        if (_toController.text.trim().isEmpty) {
                          _message('Укажите место назначения или коснитесь карты');
                        } else {
                          _message('Экран заказа готов. Подключение подачи водителей — следующий этап.');
                        }
                      },
                      icon: const Icon(Icons.local_taxi_rounded),
                      label: const Text('Продолжить', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10243A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Коснитесь карты, чтобы отметить точку назначения.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF7A8796), fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeField(IconData icon, String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF168C8C)),
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
      ),
    );
  }
}
