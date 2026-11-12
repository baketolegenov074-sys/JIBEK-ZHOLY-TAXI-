import 'package:flutter/material.dart';
import 'package:jibek_shared/jibek_shared.dart';

void main() {
  runApp(const JibekDriverApp());
}

class JibekDriverApp extends StatelessWidget {
  const JibekDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ЖІБЕК ЖОЛЫ — Водитель',
      debugShowCheckedModeBanner: false,
      theme: JibekTheme.light(),
      home: const DriverHomePage(),
    );
  }
}

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  bool _isOnline = false;

  @override
  Widget build(BuildContext context) {
    return JibekHomeShell(
      title: 'ЖІБЕК ЖОЛЫ',
      subtitle: 'Рабочее место водителя',
      roleLabel: 'ВОДИТЕЛЬ',
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _isOnline ? const Color(0xFFE8F5EE) : const Color(0xFFF1F3F6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                _isOnline ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
                color: _isOnline ? const Color(0xFF16834A) : const Color(0xFF687386),
                size: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isOnline ? 'Вы на линии' : 'Вы не на линии',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                    ),
                    const SizedBox(height: 3),
                    const Text('Переключатель пока работает локально'),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _isOnline,
                onChanged: (value) => setState(() => _isOnline = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Ваши услуги',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        const JibekServiceTile(
          icon: Icons.local_taxi_rounded,
          title: 'Городское такси',
          subtitle: 'Заказы по Шымкенту',
        ),
        const JibekServiceTile(
          icon: Icons.route_rounded,
          title: 'Межгород',
          subtitle: 'Междугородние поездки',
        ),
        const JibekServiceTile(
          icon: Icons.inventory_2_rounded,
          title: 'Доставка посылок',
          subtitle: 'Заказы на доставку',
        ),
        const JibekServiceTile(
          icon: Icons.car_crash_rounded,
          title: 'Эвакуатор и шиномонтаж',
          subtitle: 'Помощь водителям на дороге',
        ),
        const SizedBox(height: 12),
        const Text(
          'Приём реальных заказов подключим после создания серверной части.',
          style: TextStyle(color: Color(0xFF687386), height: 1.4),
        ),
      ],
    );
  }
}
