import 'package:flutter/material.dart';
import 'package:jibek_shared/jibek_shared.dart';
import 'permissions/startup_permissions.dart';

void main() => runApp(const BakeTaxiOwnerApp());

const _ink = Color(0xFF172B3A);
const _muted = Color(0xFF718096);
const _yellow = Color(0xFFFFC928);
const _surface = Color(0xFFF5F7FA);

class BakeTaxiOwnerApp extends StatelessWidget {
  const BakeTaxiOwnerApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Bake Taxi Админ',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: _surface,
          colorScheme: ColorScheme.fromSeed(seedColor: _yellow, brightness: Brightness.light,
            surface: Colors.white, primary: _ink),
          appBarTheme: const AppBarTheme(backgroundColor: _surface, foregroundColor: _ink,
            elevation: 0, centerTitle: false),
          cardTheme: CardThemeData(color: Colors.white, elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
          inputDecorationTheme: InputDecorationTheme(
            filled: true, fillColor: _surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
        ),
        home: const OwnerShell(),
      );
}

class OwnerShell extends StatefulWidget {
  const OwnerShell({super.key});
  @override
  State<OwnerShell> createState() => _OwnerShellState();
}

class _OwnerShellState extends State<OwnerShell> {
  int tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestBakeTaxiPermissions();
    });
  }
  final pages = const [OverviewPage(), DriversPage(), OrdersPage(), TariffsPage(), CashSosPage()];
  final labels = const ['Обзор', 'Водители', 'Заказы', 'Тарифы', 'Касса / SOS'];
  final icons = const [Icons.dashboard_rounded, Icons.groups_rounded, Icons.receipt_long_rounded,
    Icons.tune_rounded, Icons.account_balance_wallet_rounded];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Bake Taxi', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 21)),
        Text('КАБИНЕТ ВЛАДЕЛЬЦА • ШЫМКЕНТ',
          style: TextStyle(fontSize: 10, letterSpacing: 1.1, color: _muted)),
      ]),
      actions: [IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сервер владельца пока не подключён'))),
        icon: const Icon(Icons.sync_rounded))],
    ),
    body: SafeArea(child: IndexedStack(index: tab, children: pages)),
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: List.generate(5, (i) => NavigationDestination(
        icon: Icon(icons[i]), label: labels[i])),
    ),
  );
}

class PageTitle extends StatelessWidget {
  const PageTitle(this.title, {this.subtitle, super.key});
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: _ink)),
    if (subtitle != null) ...[const SizedBox(height: 5), Text(subtitle!, style: const TextStyle(color: _muted))],
  ]);
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10, top: 22),
    child: Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _ink)));
}

class InfoBanner extends StatelessWidget {
  const InfoBanner(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: const Color(0xFFFFF5D9), borderRadius: BorderRadius.circular(16)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.info_outline_rounded, color: Color(0xFF9A6B00)),
      const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF755514), height: 1.35))),
    ]));
}

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: [
    const PageTitle('Обзор', subtitle: 'Диспетчерская Bake Taxi'),
    const SizedBox(height: 18),
    const InfoBanner('Показатели и автомобили появятся после подключения рабочего API. Сейчас реальные данные не поступают.'),
    const SizedBox(height: 16),
    const Wrap(spacing: 10, runSpacing: 10, children: [
      MetricTile('Выручка за день', '— ₸', Icons.payments_outlined),
      MetricTile('Комиссия сервиса', '— ₸', Icons.percent_rounded),
      MetricTile('Водителей на линии', '—', Icons.local_taxi_rounded),
      MetricTile('Активных заказов', '—', Icons.route_rounded),
    ]),
    const SectionTitle('Карта Шымкента'),
    Container(height: 220, decoration: BoxDecoration(color: const Color(0xFFE9EEF2),
      borderRadius: BorderRadius.circular(22)),
      child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.map_outlined, size: 42, color: _muted),
        SizedBox(height: 8), Text('Карта и GPS водителей не подключены', style: TextStyle(color: _muted)),
      ]))),
    const SizedBox(height: 12),
    FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: _yellow, foregroundColor: _ink,
      minimumSize: const Size.fromHeight(52)),
      onPressed: () => _notice(context, 'Создание заказа станет доступно после подключения API заказов'),
      icon: const Icon(Icons.add), label: const Text('Создать заказ по телефону', style: TextStyle(fontWeight: FontWeight.w800))),
    const SectionTitle('Требуют внимания'),
    const EmptyPanel(icon: Icons.inbox_outlined, title: 'Новых заявок пока нет',
      detail: 'Заявки водителей и запросы на пополнение появятся здесь после подключения сервера.'),
  ]);
}

class MetricTile extends StatelessWidget {
  const MetricTile(this.title, this.value, this.icon, {super.key});
  final String title, value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => SizedBox(width: (MediaQuery.sizeOf(context).width - 46) / 2,
    child: Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: const Color(0xFFB18400)), const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _ink)),
        Text(title, style: const TextStyle(fontSize: 12, color: _muted)),
      ]))));
}

class DriversPage extends StatelessWidget {
  const DriversPage({super.key});
  static const services = ['Эконом', 'Комфорт', 'Бизнес', 'Межгород', 'Грузовой', 'Посылка', 'Эвакуатор', 'Шиномонтаж'];
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: [
    const PageTitle('Водители', subtitle: 'Модерация, тарифы и доступ'),
    const SectionTitle('На проверке'),
    const EmptyPanel(icon: Icons.verified_user_outlined, title: 'Нет доступных анкет',
      detail: 'После подключения сервера здесь будут ФИО, автомобиль, госномер и фотографии документов с решениями модератора.'),
    const SectionTitle('Доступ к услугам'),
    const InfoBanner('Персональные разрешения водителей пока не загружаются и не сохраняются. Ниже — перечень доступных категорий для будущих настроек.'),
    Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Категории Bake Taxi', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        ...services.map((s) => ListTile(dense: true, contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.check_circle_outline, color: _muted), title: Text(s))),
      ]))),
    const SectionTitle('Баланс и блокировка'),
    const EmptyPanel(icon: Icons.account_balance_wallet_outlined, title: 'Управление балансом недоступно',
      detail: 'Пополнение и блокировка требуют подтверждённого аккаунта владельца и серверных операций.'),
  ]);
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: [
    const PageTitle('Заказы', subtitle: 'Все категории и статусы'),
    const SizedBox(height: 16),
    const InfoBanner('Список заказов пока не связан с базой. Ручное назначение водителя и отмена будут включены после защищённого подключения API.'),
    const SizedBox(height: 20),
    const EmptyPanel(icon: Icons.receipt_long_outlined, title: 'Заказы не загружены',
      detail: 'Здесь будут текущие и завершённые поездки, доставки, грузовые и дорожные заявки.'),
  ]);
}

class TariffsPage extends StatefulWidget {
  const TariffsPage({super.key});
  @override
  State<TariffsPage> createState() => _TariffsPageState();
}

class _TariffsPageState extends State<TariffsPage> {
  final pin = TextEditingController();
  final fields = <String, TextEditingController>{
    'Такси · Эконом (₸/км)': TextEditingController(text: '120'),
    'Такси · Подача (₸)': TextEditingController(text: '300'),
    'Комфорт · надбавка (%)': TextEditingController(text: '15'),
    'Бизнес · надбавка (%)': TextEditingController(text: '30'),
    'Межгород · место (₸)': TextEditingController(),
    'Межгород · весь салон (₸)': TextEditingController(),
    'Посылка · базовая цена (₸)': TextEditingController(),
    'Грузовой · подача (₸)': TextEditingController(),
    'Грузовой · цена за км (₸)': TextEditingController(),
    'Грузчики · доплата (₸)': TextEditingController(),
    'Эвакуатор · базовая цена (₸)': TextEditingController(),
    'Шиномонтаж · базовая цена (₸)': TextEditingController(),
    'Ускорение заказа (₸)': TextEditingController(text: '250'),
    'Комиссия сервиса (%)': TextEditingController(text: '10'),
  };
  bool unlocked = false;
  bool _showPin = false;
  @override
  void dispose() { pin.dispose(); for (final c in fields.values) { c.dispose(); } super.dispose(); }

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: [
    const PageTitle('Тарифы', subtitle: 'Цены и комиссия сервиса'),
    const SizedBox(height: 16),
    const InfoBanner('Изменение цен должно проверяться сервером. PIN нельзя безопасно хранить внутри APK. Серверная проверка владельца ещё не подключена.'),
    const SectionTitle('Защищённый доступ владельца'),
    if (!unlocked) Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.lock_outline, size: 30, color: _ink),
        const SizedBox(height: 8),
        const Text('Редактирование заблокировано', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('Для настоящей проверки PIN сначала нужен защищённый сервер владельца.'),
        const SizedBox(height: 12),
        TextField(
          controller: pin,
          obscureText: !_showPin,
          keyboardType: TextInputType.visiblePassword,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            labelText: 'Пароль владельца',
            suffixIcon: IconButton(
              tooltip: _showPin ? 'Скрыть пароль' : 'Показать пароль',
              onPressed: () => setState(() => _showPin = !_showPin),
              icon: Icon(_showPin ? Icons.visibility_off : Icons.visibility),
            ),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(onPressed: () => _notice(context, 'PIN не проверяется: серверная авторизация ещё не настроена'),
          child: const Text('Проверить PIN')),
      ])))
    else ...[
      const Text('Настройки тарифов', style: TextStyle(fontWeight: FontWeight.w800)),
      ...fields.entries.map((e) => Padding(padding: const EdgeInsets.only(top: 12),
        child: TextField(controller: e.value, keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: e.key)))),
      const SizedBox(height: 16),
      FilledButton(onPressed: () => _notice(context, 'Публикация недоступна без сервера владельца'),
        child: const Text('Сохранить тарифы')),
    ],
  ]);

  void _notice(BuildContext context, String text) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
}

class CashSosPage extends StatelessWidget {
  const CashSosPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: [
    const PageTitle('Касса и SOS', subtitle: 'Финансы и безопасность'),
    const SectionTitle('Финансовый отчёт'),
    Wrap(spacing: 8, children: ['День', 'Неделя', 'Месяц'].map((s) => Chip(label: Text(s))).toList()),
    const SizedBox(height: 10),
    const MetricTile('Доход сервиса', '— ₸', Icons.trending_up_rounded),
    const SectionTitle('Сигналы SOS'),
    const EmptyPanel(icon: Icons.sos_rounded, title: 'Сигналов SOS нет',
      detail: 'Тревожные обращения водителей и пассажиров появятся после подключения канала SOS.'),
  ]);
}

class EmptyPanel extends StatelessWidget {
  const EmptyPanel({required this.icon, required this.title, required this.detail, super.key});
  final IconData icon;
  final String title, detail;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(22),
    child: Column(children: [
      Icon(icon, size: 34, color: _muted), const SizedBox(height: 10),
      Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, color: _ink)),
      const SizedBox(height: 6), Text(detail, textAlign: TextAlign.center,
        style: const TextStyle(color: _muted, height: 1.35)),
    ])));
}

void _notice(BuildContext context, String text) => ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
