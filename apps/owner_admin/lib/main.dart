import 'package:flutter/material.dart';
import 'package:jibek_shared/jibek_shared.dart';

void main() => runApp(const JibekOwnerAdminApp());

class JibekOwnerAdminApp extends StatelessWidget {
  const JibekOwnerAdminApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'ЖІБЕК ЖОЛЫ — Владелец',
        debugShowCheckedModeBanner: false,
        theme: JibekTheme.light(),
        home: const OwnerAdminHomePage(),
      );
}

class OwnerAdminHomePage extends StatefulWidget {
  const OwnerAdminHomePage({super.key});

  @override
  State<OwnerAdminHomePage> createState() => _OwnerAdminHomePageState();
}

class _OwnerAdminHomePageState extends State<OwnerAdminHomePage> {
  final _perKm = TextEditingController(text: '120');
  final _pickup = TextEditingController(text: '300');
  final _commission = TextEditingController(text: '10');
  int _tab = 0;
  final List<_DriverRecord> _drivers = [
    _DriverRecord('Новый водитель', 'Заявка ожидает проверки', false),
    _DriverRecord('Тестовый профиль', 'Проверка документов не завершена', false),
  ];

  @override
  void dispose() {
    _perKm.dispose();
    _pickup.dispose();
    _commission.dispose();
    super.dispose();
  }

  void _showNotice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ЖІБЕК ЖОЛЫ', style: TextStyle(fontWeight: FontWeight.w900)),
              Text('ПАНЕЛЬ ВЛАДЕЛЬЦА',
                  style: TextStyle(fontSize: 10, letterSpacing: 1.3, color: Color(0xFFFFE7A0), fontWeight: FontWeight.w700)),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Обновить',
              onPressed: () => _showNotice('Нет подключения к серверу владельца'),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: SafeArea(
          child: IndexedStack(
            index: _tab,
            children: [
              _dashboard(),
              _tariffs(),
              _driversPage(),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (value) => setState(() => _tab = value),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Обзор'),
            NavigationDestination(icon: Icon(Icons.payments_outlined), selectedIcon: Icon(Icons.payments), label: 'Тарифы'),
            NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups), label: 'Водители'),
          ],
        ),
      );

  Widget _dashboard() => ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF071B45), Color(0xFF17458C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE5B43C), width: 1.2),
              boxShadow: const [BoxShadow(color: Color(0x22071B45), blurRadius: 16, offset: Offset(0, 7))],
            ),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Icon(Icons.location_on_rounded, color: Color(0xFFFFE7A0), size: 28), SizedBox(width: 8), Text('ЖІБЕК ЖОЛЫ', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: .5))]),
              SizedBox(height: 12),
              Text('Добро пожаловать', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
              SizedBox(height: 5),
              Text('Управление службой такси и сервисами', style: TextStyle(color: Color(0xFFDCE7FF), fontSize: 13)),
            ]),
          ),

          const SizedBox(height: 18),
          _statusBanner(),
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(child: _MetricCard(title: 'Заказы сегодня', value: '—', icon: Icons.receipt_long)),
              SizedBox(width: 10),
              Expanded(child: _MetricCard(title: 'Водители онлайн', value: '—', icon: Icons.local_taxi)),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(child: _MetricCard(title: 'Выручка', value: '— ₸', icon: Icons.account_balance_wallet_outlined)),
              SizedBox(width: 10),
              Expanded(child: _MetricCard(title: 'Комиссия', value: '— ₸', icon: Icons.percent)),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Сервисы платформы',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          const _ServiceRow(icon: Icons.local_taxi, title: 'Городское такси', subtitle: 'Поездки по Шымкенту'),
          const _ServiceRow(icon: Icons.route, title: 'Межгород', subtitle: 'Поездки по Казахстану'),
          const _ServiceRow(icon: Icons.inventory_2_outlined, title: 'Доставка посылок', subtitle: 'Передача и доставка отправлений'),
          const _ServiceRow(icon: Icons.car_crash_outlined, title: 'Эвакуатор', subtitle: 'Помощь на дороге'),
          const _ServiceRow(icon: Icons.tire_repair, title: 'Выездной шиномонтаж', subtitle: 'Помощь с колёсами'),
        ],
      );

  Widget _statusBanner() => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4DE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: Color(0xFF9A6818)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Демонстрационный режим. Тарифы пока редактируются только на экране; серверное сохранение и реальные показатели подключим после настройки защищённого доступа владельца.',
                style: TextStyle(height: 1.35, color: Color(0xFF684A1C)),
              ),
            ),
          ],
        ),
      );

  Widget _tariffs() => ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('Тарифы и комиссия',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Черновые значения для настройки. Пока не опубликованы.',
              style: TextStyle(color: Color(0xFF687386))),
          const SizedBox(height: 20),
          _numberField('Цена за километр (₸)', _perKm, suffix: '₸/км'),
          const SizedBox(height: 14),
          _numberField('Подача автомобиля (₸)', _pickup, suffix: '₸'),
          const SizedBox(height: 14),
          _numberField('Комиссия платформы (%)', _commission, suffix: '%'),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {
              final values = [_perKm.text, _pickup.text, _commission.text];
              final valid = values.every((v) => double.tryParse(v.replaceAll(',', '.')) != null);
              if (!valid) {
                _showNotice('Проверьте введённые числовые значения');
                return;
              }
              _showNotice('Черновик проверен. Для публикации нужно подключить сервер владельца.');
            },
            icon: const Icon(Icons.save_outlined),
            label: const Text('Проверить настройки'),
          ),
          const SizedBox(height: 12),
          const Text('Изменения сейчас не влияют на стоимость поездок.',
              style: TextStyle(color: Color(0xFF9A6818), fontSize: 12)),
        ],
      );

  Widget _numberField(String label, TextEditingController controller, {required String suffix}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 7),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              suffixText: suffix,
              prefixIcon: const Icon(Icons.edit_outlined),
            ),
          ),
        ],
      );

  Widget _driversPage() => ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('Водители',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Макет проверки заявок водителей',
              style: TextStyle(color: Color(0xFF687386))),
          const SizedBox(height: 16),
          ..._drivers.map((driver) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const CircleAvatar(child: Icon(Icons.person_outline)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(driver.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                            Text(driver.details, style: const TextStyle(fontSize: 12, color: Color(0xFF687386))),
                          ],
                        )),
                        Chip(label: Text(driver.approved ? 'Одобрен' : 'Ожидает')),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(child: OutlinedButton(
                          onPressed: () => _showNotice('Проверка документов будет доступна после подключения базы'),
                          child: const Text('Документы'),
                        )),
                        const SizedBox(width: 8),
                        Expanded(child: FilledButton(
                          onPressed: () => setState(() => driver.approved = !driver.approved),
                          child: Text(driver.approved ? 'Отозвать' : 'Одобрить (макет)'),
                        )),
                      ]),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 10),
          const Text('Кнопка одобрения пока меняет только демонстрационный экран и не выдаёт доступ к реальным заказам.',
              style: TextStyle(fontSize: 12, color: Color(0xFF9A6818))),
        ],
      );
}

class _DriverRecord {
  _DriverRecord(this.name, this.details, this.approved);
  final String name;
  final String details;
  bool approved;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value, required this.icon});
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFFD6A52F)),
              const SizedBox(height: 12),
              Text(value, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
              Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF687386))),
            ],
          ),
        ),
      );
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFFD6A52F)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text(subtitle),
        ),
      );
}
