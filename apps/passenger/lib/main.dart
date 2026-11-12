import 'package:flutter/material.dart';
import 'package:jibek_shared/jibek_shared.dart';

void main() {
  runApp(const JibekPassengerApp());
}

class JibekPassengerApp extends StatelessWidget {
  const JibekPassengerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ЖІБЕК ЖОЛЫ',
      debugShowCheckedModeBanner: false,
      theme: JibekTheme.light(),
      home: const PassengerHomePage(),
    );
  }
}

class PassengerHomePage extends StatelessWidget {
  const PassengerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return JibekHomeShell(
      title: 'ЖІБЕК ЖОЛЫ',
      subtitle: 'Поездки и услуги по Казахстану',
      roleLabel: 'ПАССАЖИР',
      children: [
        const Text(
          'Куда направимся?',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        JibekServiceTile(
          icon: Icons.local_taxi_rounded,
          title: 'Городское такси',
          subtitle: 'Поездки по Шымкенту',
          onTap: () => _showComingSoon(context, 'Городское такси'),
        ),
        JibekServiceTile(
          icon: Icons.route_rounded,
          title: 'Межгород',
          subtitle: 'По всему Казахстану',
          onTap: () => _showComingSoon(context, 'Межгород'),
        ),
        JibekServiceTile(
          icon: Icons.inventory_2_rounded,
          title: 'Доставка посылок',
          subtitle: 'Передача и доставка отправлений',
          onTap: () => _showComingSoon(context, 'Доставка посылок'),
        ),
        JibekServiceTile(
          icon: Icons.car_crash_rounded,
          title: 'Эвакуатор',
          subtitle: 'Помощь на дороге',
          onTap: () => _showComingSoon(context, 'Эвакуатор'),
        ),
        JibekServiceTile(
          icon: Icons.tire_repair_rounded,
          title: 'Выездной шиномонтаж',
          subtitle: 'Ремонт колёс на месте',
          onTap: () => _showComingSoon(context, 'Выездной шиномонтаж'),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String service) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$service: подключим на следующем этапе')),
    );
  }
}
