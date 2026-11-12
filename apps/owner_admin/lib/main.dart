import 'package:flutter/material.dart';

void main() => runApp(const JibekOwnerAdminApp());

class JibekOwnerAdminApp extends StatelessWidget {
  const JibekOwnerAdminApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'ЖІБЕК ЖОЛЫ — Администратор',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF168C8C)),
          useMaterial3: true,
        ),
        home: const OwnerAdminHomePage(),
      );
}

class OwnerAdminHomePage extends StatelessWidget {
  const OwnerAdminHomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('ЖІБЕК ЖОЛЫ — Владелец')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.admin_panel_settings_outlined, size: 64),
                SizedBox(height: 16),
                Text(
                  'Кабинет владельца',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Основа третьего приложения создана. Подключение Firebase, '
                  'управление водителями, тарифами и комиссиями будет выполнено '
                  'на следующих этапах.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
}
