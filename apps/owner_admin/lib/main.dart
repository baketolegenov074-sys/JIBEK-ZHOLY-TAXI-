import 'package:flutter/material.dart';
import 'package:jibek_shared/jibek_shared.dart';

void main() => runApp(const JibekOwnerAdminApp());

class JibekOwnerAdminApp extends StatelessWidget {
  const JibekOwnerAdminApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'ЖІБЕК ЖОЛЫ — Владелец',
        debugShowCheckedModeBanner: false,
        theme: JibekTheme.light().copyWith(
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE6EBF3)),
            ),
          ),
          inputDecorationTheme: JibekTheme.light().inputDecorationTheme.copyWith(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE1E7F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: JibekTheme.gold, width: 1.6),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(0, 48),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(0, 44),
            ),
          ),
        ),
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

  void _notice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _goTo(int index) => setState(() => _tab = index);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          toolbarHeight: 72,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ЖІБЕК ЖОЛЫ', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: .4)),
              SizedBox(height: 3),
              Text('ПАНЕЛЬ ВЛАДЕЛЬЦА',
                  style: TextStyle(fontSize: 10, letterSpacing: 1.4, color: JibekTheme.goldLight, fontWeight: FontWeight.w800)),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Уведомления',
              onPressed: () => _notice('Новых уведомлений пока нет'),
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: IndexedStack(
            index: _tab,
            children: [_dashboard(), _tariffs(), _driversPage()],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: _goTo,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.grid_view_rounded), selectedIcon: Icon(Icons.grid_view_rounded), label: 'Обзор'),
            NavigationDestination(icon: Icon(Icons.payments_outlined), selectedIcon: Icon(Icons.payments_rounded), label: 'Тарифы'),
            NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups_rounded), label: 'Водители'),
          ],
        ),
      );

  Widget _dashboard() => ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Добро пожаловать', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text('Центр управления', style: Theme.of(context).textTheme.headlineMedium),
                ]),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2CC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.admin_panel_settings_rounded, color: JibekTheme.navy, size: 27),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _statusBanner(),
          const SizedBox(height: 24),
          _sectionTitle('Состояние платформы', 'Данные появятся после подключения сервера'),
          const SizedBox(height: 12),
          const Row(children: [
            Expanded(child: _MetricCard(title: 'Заказы сегодня', value: '—', icon: Icons.receipt_long_rounded)),
            SizedBox(width: 12),
            Expanded(child: _MetricCard(title: 'Водители онлайн', value: '—', icon: Icons.local_taxi_rounded)),
          ]),
          const SizedBox(height: 12),
          const Row(children: [
            Expanded(child: _MetricCard(title: 'Выручка', value: '— ₸', icon: Icons.account_balance_wallet_outlined)),
            SizedBox(width: 12),
            Expanded(child: _MetricCard(title: 'Комиссия', value: '— ₸', icon: Icons.percent_rounded)),
          ]),
          const SizedBox(height: 24),
          _sectionTitle('Быстрый доступ', 'Основные инструменты владельца'),
          const SizedBox(height: 12),
          _QuickAction(
            icon: Icons.tune_rounded,
            title: 'Управление тарифами',
            subtitle: 'Цена за километр, подача и комиссия',
            onTap: () => _goTo(1),
          ),
          const SizedBox(height: 10),
          _QuickAction(
            icon: Icons.verified_user_outlined,
            title: 'Заявки водителей',
            subtitle: 'Просмотр демонстрационных профилей',
            onTap: () => _goTo(2),
          ),
          const SizedBox(height: 24),
          _sectionTitle('Сервисы платформы', 'Направления работы ЖІБЕК ЖОЛЫ'),
          const SizedBox(height: 12),
          const _ServiceRow(icon: Icons.local_taxi_rounded, title: 'Городское такси', subtitle: 'Поездки по городу'),
          const SizedBox(height: 8),
          const _ServiceRow(icon: Icons.route_rounded, title: 'Межгород', subtitle: 'Поездки между городами'),
          const SizedBox(height: 8),
          const _ServiceRow(icon: Icons.inventory_2_outlined, title: 'Доставка посылок', subtitle: 'Передача и доставка отправлений'),
          const SizedBox(height: 8),
          const _ServiceRow(icon: Icons.car_crash_outlined, title: 'Эвакуатор', subtitle: 'Помощь на дороге'),
          const SizedBox(height: 8),
          const _ServiceRow(icon: Icons.tire_repair_rounded, title: 'Выездной шиномонтаж', subtitle: 'Помощь с колёсами'),
        ],
      );

  Widget _sectionTitle(String title, String subtitle) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: JibekTheme.ink)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: JibekTheme.muted)),
        ],
      );

  Widget _statusBanner() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5DF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0D99E)),
        ),
        child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF936516), size: 21),
          SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Демонстрационный режим', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF684A1C))),
            SizedBox(height: 5),
            Text(
              'Панель пока не получает данные с сервера. Тарифы и статусы водителей на этом экране не публикуются и не меняют реальные поездки.',
              style: TextStyle(height: 1.4, fontSize: 12, color: Color(0xFF684A1C)),
            ),
          ])),
        ]),
      );

  Widget _tariffs() => ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        children: [
          Text('Тарифы', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          const Text('Черновые параметры платформы', style: TextStyle(color: JibekTheme.muted)),
          const SizedBox(height: 20),
          _statusBanner(),
          const SizedBox(height: 24),
          _numberField('Цена за километр', _perKm, suffix: '₸/км'),
          const SizedBox(height: 16),
          _numberField('Подача автомобиля', _pickup, suffix: '₸'),
          const SizedBox(height: 16),
          _numberField('Комиссия платформы', _commission, suffix: '%'),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              final values = [_perKm.text, _pickup.text, _commission.text];
              final parsed = values.map((v) => double.tryParse(v.replaceAll(',', '.'))).toList();
              if (parsed.any((v) => v == null || !v.isFinite || v < 0)) {
                _notice('Введите корректные неотрицательные числа');
                return;
              }
              if (parsed.last! > 100) {
                _notice('Комиссия не может превышать 100%');
                return;
              }
              _notice('Черновик проверен. Сохранение станет доступно после подключения сервера.');
            },
            icon: const Icon(Icons.fact_check_outlined),
            label: const Text('Проверить параметры'),
          ),
          const SizedBox(height: 12),
          const Text('Изменения сохраняются только в текущем открытом экране.',
              style: TextStyle(fontSize: 12, color: JibekTheme.muted)),
        ],
      );

  Widget _numberField(String label, TextEditingController controller, {required String suffix}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800, color: JibekTheme.ink)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Введите значение',
              suffixText: suffix,
              prefixIcon: const Icon(Icons.edit_outlined),
            ),
          ),
        ],
      );

  Widget _driversPage() => ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        children: [
          Text('Водители', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          const Text('Демонстрационные заявки для проверки интерфейса',
              style: TextStyle(color: JibekTheme.muted)),
          const SizedBox(height: 18),
          _statusBanner(),
          const SizedBox(height: 20),
          ..._drivers.map((driver) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DriverCard(
                  driver: driver,
                  onDocuments: () => _notice('Документы будут доступны после подключения базы'),
                  onToggle: () => setState(() => driver.approved = !driver.approved),
                ),
              )),
          const SizedBox(height: 4),
          const Text(
            'Статус одобрения меняется только в демонстрационном интерфейсе и не выдаёт доступ к реальным заказам.',
            style: TextStyle(fontSize: 12, height: 1.4, color: JibekTheme.muted),
          ),
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
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: const Color(0xFFFFF3D2), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: const Color(0xFF9B741F), size: 21),
            ),
            const SizedBox(height: 16),
            Text(value, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: JibekTheme.navy)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, color: JibekTheme.muted)),
          ]),
        ),
      );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: const Color(0xFFFFF3D2), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: JibekTheme.navy, size: 23),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: JibekTheme.ink)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: JibekTheme.muted)),
              ])),
              const Icon(Icons.chevron_right_rounded, color: JibekTheme.gold, size: 25),
            ]),
          ),
        ),
      );
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.driver, required this.onDocuments, required this.onToggle});
  final _DriverRecord driver;
  final VoidCallback onDocuments;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: const Color(0xFFF0F3F8), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.person_outline_rounded, color: JibekTheme.navy),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(driver.name, style: const TextStyle(fontWeight: FontWeight.w900, color: JibekTheme.ink)),
                const SizedBox(height: 3),
                Text(driver.details, style: const TextStyle(fontSize: 12, color: JibekTheme.muted)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: driver.approved ? const Color(0xFFE5F5EB) : const Color(0xFFFFF3D9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  driver.approved ? 'Одобрен' : 'Ожидает',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                    color: driver.approved ? const Color(0xFF287447) : const Color(0xFF8A6418)),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: onDocuments, child: const Text('Документы'))),
              const SizedBox(width: 10),
              Expanded(child: FilledButton(onPressed: onToggle, child: Text(driver.approved ? 'Отозвать' : 'Одобрить (макет)'))),
            ]),
          ]),
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
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: const Color(0xFFF0F3F8), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: JibekTheme.navy, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: JibekTheme.ink)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: JibekTheme.muted)),
            ])),
            const Icon(Icons.chevron_right_rounded, color: JibekTheme.gold),
          ]),
        ),
      );
}
