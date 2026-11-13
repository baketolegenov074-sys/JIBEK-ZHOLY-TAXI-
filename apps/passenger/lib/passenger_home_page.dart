import 'package:flutter/material.dart';
import 'package:jibek_shared/jibek_shared.dart';

import 'main.dart' show PassengerMapPage;

/// Главная страница пассажирского приложения.
/// Реальный экран заказа сохранён в PassengerMapPage.
class PassengerHomePage extends StatefulWidget {
  const PassengerHomePage({super.key});

  @override
  State<PassengerHomePage> createState() => _PassengerHomePageState();
}

class _PassengerHomePageState extends State<PassengerHomePage> {
  static const navy = Color(0xFF102B50);
  static const gold = Color(0xFFFFC928);
  static const paleBlue = Color(0xFFEAF3FC);
  static const background = Color(0xFFF7F9FC);

  final _addressController = TextEditingController();
  int _selectedTab = 0;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _openOrder({
    JibekServiceType service = JibekServiceType.cityTaxi,
    String? destination,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PassengerMapPage(
          initialService: service,
          initialDestination: destination,
        ),
      ),
    );
  }

  void _selectTab(int index) {
    setState(() => _selectedTab = index);
    if (index == 0) return;
    if (index == 1) {
      _openOrder();
      return;
    }
    final label = index == 2 ? 'Избранное' : 'Профиль';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Раздел «$label» будет подключён отдельно')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: navy,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.route_rounded, color: gold, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ЖІБЕК ЖОЛЫ',
                            style: TextStyle(color: navy, fontSize: 19,
                                fontWeight: FontWeight.w900, letterSpacing: .5)),
                        SizedBox(height: 3),
                        Text('Ваш надёжный попутчик',
                            style: TextStyle(color: Color(0xFF748093), fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Уведомления скоро появятся')),
                    ),
                    icon: const Icon(Icons.notifications_none_rounded,
                        color: navy, size: 27),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text('Куда поедем?',
                  style: TextStyle(color: navy, fontSize: 25,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              Container(
                height: 60,
                padding: const EdgeInsets.only(left: 16, right: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF0F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: navy, size: 25),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _addressController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _openOrder(destination: _addressController.text.trim()),
                        decoration: const InputDecoration(
                          hintText: 'Введите адрес...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Color(0xFF8993A1), fontSize: 15),
                        ),
                      ),
                    ),
                    Material(
                      color: gold,
                      shape: const CircleBorder(),
                      child: IconButton(
                        onPressed: () => _openOrder(destination: _addressController.text.trim()),
                        icon: const Icon(Icons.arrow_forward_rounded,
                            color: navy, size: 23),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.18,
                children: [
                  _ActionTile(icon: Icons.local_taxi_rounded,
                      title: 'Вызвать такси',
                      onTap: () => _openOrder(service: JibekServiceType.cityTaxi)),
                  _ActionTile(icon: Icons.map_rounded,
                      title: 'На карте', onTap: () => _openOrder()),
                  _ActionTile(icon: Icons.inventory_2_rounded,
                      title: 'Доставка',
                      onTap: () => _openOrder(service: JibekServiceType.parcel)),
                  _ActionTile(icon: Icons.directions_car_rounded,
                      title: 'Межгород',
                      onTap: () => _openOrder(service: JibekServiceType.intercity)),
                ],
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  height: 174,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF07172D), Color(0xFF183D68), Color(0xFF31577A)],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -12,
                        bottom: -28,
                        child: Transform.rotate(
                          angle: -.18,
                          child: const Icon(Icons.route_rounded,
                              color: Color(0x334FC0E8), size: 190),
                        ),
                      ),
                      Positioned(
                        right: 66,
                        top: 24,
                        child: Icon(Icons.nightlight_round,
                            color: Colors.white.withOpacity(.55), size: 27),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'ЖІБЕК ЖОЛЫ\nВаш надёжный попутчик!',
                                style: TextStyle(color: gold, fontSize: 19,
                                    height: 1.35, fontWeight: FontWeight.w900),
                              ),
                            ),
                            Material(
                              color: gold,
                              shape: const CircleBorder(),
                              child: IconButton(
                                onPressed: _openOrder,
                                icon: const Icon(Icons.arrow_forward_rounded,
                                    color: navy, size: 23),
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
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: navy,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _TabItem(icon: Icons.home_rounded, label: 'Главная',
                  active: _selectedTab == 0, onTap: () => _selectTab(0)),
              _TabItem(icon: Icons.receipt_long_rounded, label: 'Заказы',
                  active: _selectedTab == 1, onTap: () => _selectTab(1)),
              _TabItem(icon: Icons.favorite_rounded, label: 'Избранное',
                  active: _selectedTab == 2, onTap: () => _selectTab(2)),
              _TabItem(icon: Icons.person_rounded, label: 'Профиль',
                  active: _selectedTab == 3, onTap: () => _selectTab(3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFEAF3FC),
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF102B50), size: 36),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF102B50),
                    fontSize: 14, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    ),
  );
}

class _TabItem extends StatelessWidget {
  const _TabItem({required this.icon, required this.label,
      required this.active, required this.onTap});
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? const Color(0xFFFFC928) : Colors.white70,
              size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(
            color: active ? const Color(0xFFFFC928) : Colors.white70,
            fontSize: 11,
            fontWeight: active ? FontWeight.w800 : FontWeight.w500,
          )),
        ],
      ),
    ),
  );
}
