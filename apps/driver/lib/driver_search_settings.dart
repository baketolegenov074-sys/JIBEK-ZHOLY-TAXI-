import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

Future<void> showDriverSearchSettings(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _DriverSearchSettings(),
  );
}

class _DriverSearchSettings extends StatefulWidget {
  const _DriverSearchSettings();
  @override
  State<_DriverSearchSettings> createState() => _DriverSearchSettingsState();
}

class _DriverSearchSettingsState extends State<_DriverSearchSettings> {
  final Set<String> _modes = {'Домой'};
  final Set<String> _tariffs = {'Эконом'};
  static const yellow = Color(0xFFFFD400);
  static const ink = Color(0xFF17212B);

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    expand: false, initialChildSize: .88, minChildSize: .6, maxChildSize: .96,
    builder: (context, scroll) => Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: ListView(controller: scroll, padding: const EdgeInsets.fromLTRB(20, 12, 20, 30), children: [
        Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: const Color(0xFFD9DDE2), borderRadius: BorderRadius.circular(8)))),
        const SizedBox(height: 18),
        Row(children: [
          const Expanded(child: Text('Настройки поиска', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: ink))),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, size: 28)),
        ]),
        const SizedBox(height: 22),
        const Text('Режимы и «Мой район»', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Wrap(spacing: 9, runSpacing: 9, children: [
          _mode('Домой', Icons.home_rounded), _mode('По делам', Icons.work_outline_rounded),
          _mode('Мой район', Icons.location_city_rounded), _mode('Межгород', Icons.route_rounded),
        ]),
        const SizedBox(height: 22),
        const Text('Тарифы и опции', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.2,
          children: [
            _tariff('Межгород'), _tariff('Эконом'), _tariff('Комфорт'), _tariff('Доставка'),
            _tariff('Грузовой'), _tariff('Эвакуатор'), _tariff('Шиномонтаж'),
            _tariff('Перевозка домашних животных', wide: true),
          ],
        ),
        const SizedBox(height: 22),
        const Text('Улучшить геопозицию', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        FutureBuilder<bool>(
          future: Geolocator.isLocationServiceEnabled(),
          builder: (context, snapshot) => Row(children: [
            Expanded(child: _checkCard(Icons.my_location_rounded, 'GPS / геопозиция',
              snapshot.connectionState == ConnectionState.waiting ? 'Проверяем…' : (snapshot.data == true ? 'Включена' : 'Выключена'),
              snapshot.data == true)),
            const SizedBox(width: 10),
            Expanded(child: _checkCard(Icons.wifi_rounded, 'Связь с сервером', 'Проверяется при запросе заказов', null)),
          ]),
        ),
        const SizedBox(height: 14),
        const Text('Выбранные тарифы и режимы сохраняются в этом окне. Приём заказов продолжает работать через текущую систему водителя.',
          style: TextStyle(color: Color(0xFF77818B), fontSize: 12, height: 1.4)),
      ]),
    ),
  );

  Widget _mode(String label, IconData icon) {
    final selected = _modes.contains(label);
    return FilterChip(
      avatar: Icon(icon, size: 18, color: selected ? ink : const Color(0xFF59636D)),
      label: Text(label), selected: selected, showCheckmark: false,
      selectedColor: const Color(0xFFFFE76A),
      onSelected: (v) => setState(() => v ? _modes.add(label) : _modes.remove(label)),
    );
  }

  Widget _tariff(String label, {bool wide = false}) {
    final selected = _tariffs.contains(label);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => setState(() => selected ? _tariffs.remove(label) : _tariffs.add(label)),
      child: Container(
        width: wide ? double.infinity : null,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(color: selected ? yellow : const Color(0xFFEEEEF0), borderRadius: BorderRadius.circular(18)),
        child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ink)),
      ),
    );
  }

  Widget _checkCard(IconData icon, String title, String status, bool? ok) => Container(
    constraints: const BoxConstraints(minHeight: 112),
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: const Color(0xFFF0F1F2), borderRadius: BorderRadius.circular(18)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CircleAvatar(backgroundColor: ok == false ? const Color(0xFFB9BEC4) : const Color(0xFF07945C), child: Icon(icon, color: Colors.white)),
      const SizedBox(height: 10),
      Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      const SizedBox(height: 3),
      Text(status, style: const TextStyle(color: Color(0xFF737C84), fontSize: 11)),
    ]),
  );
}
