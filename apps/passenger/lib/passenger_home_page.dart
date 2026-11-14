import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jibek_shared/jibek_shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

const _ink = Color(0xFF10243A);
const _gold = Color(0xFFE3BD70);
const _surface = Colors.white;
const _page = Color(0xFFF7F7F5);
const _muted = Color(0xFF687386);

class PassengerHomePage extends StatelessWidget {
  const PassengerHomePage({super.key});

  void _open(BuildContext context, JibekServiceType service) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PassengerMapPage(initialService: service),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _page,
    drawer: const _PassengerDrawer(),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
        children: [
          Row(children: [
            Builder(builder: (drawerContext) => IconButton(
              onPressed: () => Scaffold.of(drawerContext).openDrawer(),
              icon: const Icon(Icons.menu_rounded, size: 28),
            )),
            const Spacer(),
            const Text('Bake Taxi', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: .3, color: _ink)),
            const Spacer(),
            IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PassengerProfilePage())), icon: const Icon(Icons.account_circle_outlined, size: 28)),
          ]),
          const Row(children: [
            Icon(Icons.location_on_rounded, color: Color(0xFFB58A16), size: 18),
            SizedBox(width: 5),
            Expanded(child: Text('Шымкент • Определяем адрес по GPS', style: TextStyle(color: _muted, fontSize: 12))),
          ]),
          const SizedBox(height: 20),
          const Text('Куда отправимся?', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: _ink)),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.45,
            children: [
              _ServiceCard(title: 'Такси', subtitle: 'от 4 мин', icon: Icons.local_taxi_rounded, color: const Color(0xFFEAF0F6), onTap: () => _open(context, JibekServiceType.cityTaxi)),
              _ServiceCard(title: 'Доставка', subtitle: 'Посылка', icon: Icons.inventory_2_rounded, color: const Color(0xFFF2F4F7), onTap: () => _open(context, JibekServiceType.parcel)),
              _ServiceCard(title: 'Межгород', subtitle: 'В другой город', icon: Icons.route_rounded, color: const Color(0xFFF2F4F7), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IntercityPage()))),
              _ServiceCard(title: 'Грузовой', subtitle: 'Перевозка вещей', icon: Icons.local_shipping_rounded, color: const Color(0xFFEAF0F6), onTap: () => _open(context, JibekServiceType.freight)),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Ещё услуги', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _ink)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _SmallService(icon: Icons.car_crash_rounded, title: 'Эвакуатор', onTap: () => _open(context, JibekServiceType.towTruck))),
            Expanded(child: _SmallService(icon: Icons.tire_repair_rounded, title: 'Шиномонтаж', onTap: () => _open(context, JibekServiceType.mobileTire))),
            Expanded(child: _SmallService(icon: Icons.airline_seat_recline_extra_rounded, title: 'Комфорт / Бизнес', onTap: () => _open(context, JibekServiceType.cityTaxi))),
          ]),
          const SizedBox(height: 22),
          Material(
            color: Colors.white, borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _open(context, JibekServiceType.cityTaxi),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 17),
                child: Row(children: [
                  Icon(Icons.search_rounded, color: _ink, size: 25),
                  SizedBox(width: 12),
                  Expanded(child: Text('Куда едем?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _ink))),
                  Icon(Icons.arrow_forward_ios_rounded, size: 16, color: _muted),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Популярное в Шымкенте', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _ink)),
          const SizedBox(height: 6),
          _AddressRow(icon: Icons.flight_rounded, title: 'Аэропорт Шымкент', onTap: () => _open(context, JibekServiceType.cityTaxi)),
          _AddressRow(icon: Icons.train_rounded, title: 'Железнодорожный вокзал', onTap: () => _open(context, JibekServiceType.cityTaxi)),
          _AddressRow(icon: Icons.shopping_bag_outlined, title: 'ТРЦ Shymkent Plaza', onTap: () => _open(context, JibekServiceType.cityTaxi)),
        ],
      ),
    ),
  );
}


class _PassengerDrawer extends StatelessWidget {
  const _PassengerDrawer();

  @override
  Widget build(BuildContext context) => Drawer(
    backgroundColor: _surface,
    child: SafeArea(child: ListView(padding: EdgeInsets.zero, children: [
      Container(
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
        decoration: const BoxDecoration(color: _ink),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(radius: 27, backgroundColor: _gold, child: Icon(Icons.local_taxi_rounded, color: _ink, size: 30)),
          SizedBox(height: 12),
          Text('Bake Taxi', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          Text('Пассажирское приложение', style: TextStyle(color: Color(0xFFD9E0E8), fontSize: 12)),
        ]),
      ),
      _drawerItem(context, Icons.home_rounded, 'Главная', () => Navigator.pop(context)),
      _drawerItem(context, Icons.receipt_long_rounded, 'Мои поездки', () {
        Navigator.pop(context);
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PassengerProfilePage()));
      }),
      _drawerItem(context, Icons.favorite_border_rounded, 'Избранные адреса', () {
        Navigator.pop(context);
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PassengerFavoritesPage()));
      }),
      _drawerItem(context, Icons.credit_card_rounded, 'Способы оплаты', () => _showInfo(context, 'Способы оплаты')),
      _drawerItem(context, Icons.notifications_none_rounded, 'Уведомления', () => _showInfo(context, 'Уведомления')),
      _drawerItem(context, Icons.help_outline_rounded, 'Поддержка', () => _showInfo(context, 'Поддержка')),
      _drawerItem(context, Icons.info_outline_rounded, 'О приложении', () => _showInfo(context, 'Bake Taxi')),
    ])),
  );

  Widget _drawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap) =>
    ListTile(leading: Icon(icon, color: _ink), title: Text(title, style: const TextStyle(color: _ink, fontWeight: FontWeight.w700)), onTap: onTap);

  void _showInfo(BuildContext context, String title) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title — раздел будет подключён отдельно')));
  }
}

class PassengerProfilePage extends StatefulWidget {
  const PassengerProfilePage({super.key});
  @override
  State<PassengerProfilePage> createState() => _PassengerProfilePageState();
}

class _PassengerProfilePageState extends State<PassengerProfilePage> {
  static const _historyKey = 'bake_taxi_order_history';
  List<JibekOrderRequest> _orders = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadHistory(); }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_historyKey) ?? const <String>[];
      final orders = raw.map((item) => JibekOrderRequest.fromJson(
        Map<String, Object?>.from(jsonDecode(item) as Map),
      )).toList();
      if (mounted) setState(() { _orders = orders; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _orders = []; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _page,
    appBar: AppBar(title: const Text('Профиль'), backgroundColor: _surface, foregroundColor: _ink, elevation: 0),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: _ink, borderRadius: BorderRadius.circular(24)),
        child: const Column(children: [
          CircleAvatar(radius: 38, backgroundColor: _gold, child: Icon(Icons.person_rounded, color: _ink, size: 42)),
          SizedBox(height: 12),
          Text('Пассажир Bake Taxi', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
          SizedBox(height: 4),
          Text('Ваш профиль', style: TextStyle(color: Color(0xFFD9E0E8))),
        ]),
      ),
      const SizedBox(height: 14),
      const SizedBox(height: 18),
      const Text('Последние поездки', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _ink)),
      const SizedBox(height: 8),
      if (_loading) const Center(child: Padding(padding: EdgeInsets.all(18), child: CircularProgressIndicator()))
      else if (_orders.isEmpty) const Card(color: _surface, child: Padding(padding: EdgeInsets.all(16), child: Text('Пока поездок нет. Здесь появятся ваши оформленные заказы.', style: TextStyle(color: _muted))))
      else ..._orders.take(10).map((order) => Card(
        color: _surface, elevation: 0, margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const Icon(Icons.local_taxi_rounded, color: _ink),
          title: Text(order.destination.address ?? 'Заказ ${order.id}', maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('${_serviceTitle(order.service)} • ${_statusTitle(order.status)}'),
          trailing: Text('${order.createdAt.toLocal().day.toString().padLeft(2, '0')}.${order.createdAt.toLocal().month.toString().padLeft(2, '0')}.${order.createdAt.toLocal().year}', style: const TextStyle(fontSize: 11, color: _muted)),
        ),
      )),
      _profileItem(Icons.receipt_long_rounded, 'История заказов'),
      _profileItem(Icons.favorite_border_rounded, 'Избранные адреса', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PassengerFavoritesPage()))),
      _profileItem(Icons.credit_card_rounded, 'Способы оплаты'),
      _profileItem(Icons.notifications_none_rounded, 'Уведомления'),
      _profileItem(Icons.help_outline_rounded, 'Поддержка'),
      _profileItem(Icons.info_outline_rounded, 'О приложении'),
    ]),
  );

  String _serviceTitle(JibekServiceType service) => switch (service) {
    JibekServiceType.cityTaxi => 'Такси', JibekServiceType.intercity => 'Межгород',
    JibekServiceType.parcel => 'Доставка', JibekServiceType.freight => 'Грузовой',
    JibekServiceType.towTruck => 'Эвакуатор', JibekServiceType.mobileTire => 'Шиномонтаж',
  };

  String _statusTitle(JibekOrderStatus status) => switch (status) {
    JibekOrderStatus.draft => 'Черновик', JibekOrderStatus.searching => 'Ищем водителя',
    JibekOrderStatus.accepted => 'Водитель найден', JibekOrderStatus.driverArriving => 'Водитель едет',
    JibekOrderStatus.inProgress => 'В поездке', JibekOrderStatus.completed => 'Завершена',
    JibekOrderStatus.cancelled => 'Отменена',
  };

  Widget _profileItem(IconData icon, String title, {VoidCallback? onTap}) => Card(
    color: _surface, elevation: 0, margin: const EdgeInsets.only(bottom: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ListTile(leading: Icon(icon, color: _ink), title: Text(title, style: const TextStyle(color: _ink, fontWeight: FontWeight.w700)), trailing: const Icon(Icons.chevron_right_rounded, color: _muted), onTap: onTap),
  );
}


class PassengerFavoritesPage extends StatefulWidget {
  const PassengerFavoritesPage({super.key});

  @override
  State<PassengerFavoritesPage> createState() => _PassengerFavoritesPageState();
}

class _PassengerFavoritesPageState extends State<PassengerFavoritesPage> {
  static const _favoritesKey = 'bake_taxi_favorite_addresses';
  List<String> _addresses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _addresses = prefs.getStringList(_favoritesKey) ?? [];
      _loading = false;
    });
  }

  Future<void> _addAddress() async {
    final controller = TextEditingController();
    final address = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Новый адрес'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Название или адрес'),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Отмена')),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (address == null || address.isEmpty || !mounted) return;
    if (_addresses.any((item) => item.toLowerCase() == address.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Этот адрес уже сохранён')));
      return;
    }
    final updated = [..._addresses, address];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, updated);
    if (mounted) setState(() => _addresses = updated);
  }

  Future<void> _removeAddress(String address) async {
    final updated = _addresses.where((item) => item != address).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, updated);
    if (mounted) setState(() => _addresses = updated);
  }

  void _selectAddress(String address) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PassengerMapPage(
        initialService: JibekServiceType.cityTaxi,
        initialDestination: address,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _page,
    appBar: AppBar(
      title: const Text('Избранные адреса'),
      backgroundColor: _surface,
      foregroundColor: _ink,
      elevation: 0,
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _addAddress,
      backgroundColor: _gold,
      foregroundColor: _ink,
      icon: const Icon(Icons.add),
      label: const Text('Добавить адрес'),
    ),
    body: _loading
      ? const Center(child: CircularProgressIndicator())
      : _addresses.isEmpty
        ? const Center(child: Padding(
            padding: EdgeInsets.all(28),
            child: Text('Здесь будут ваши любимые адреса. Нажмите «Добавить адрес», чтобы сохранить первый.', textAlign: TextAlign.center, style: TextStyle(color: _muted)),
          ))
        : ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            itemCount: _addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final address = _addresses[index];
              return Card(
                color: _surface,
                elevation: 0,
                child: ListTile(
                  leading: const Icon(Icons.favorite_rounded, color: _ink),
                  title: Text(address, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: const Text('Нажмите, чтобы выбрать адрес назначения'),
                  onTap: () => _selectAddress(address),
                  trailing: IconButton(
                    tooltip: 'Удалить адрес',
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () => _removeAddress(address),
                  ),
                ),
              );
            },
          ),
  );
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: _surface, borderRadius: BorderRadius.circular(22),
    child: InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFDCE3EB))), child: Icon(icon, color: _ink, size: 27)),
          const Spacer(),
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _ink)),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: _muted)),
        ]),
      ),
    ),
  );
}

class _SmallService extends StatelessWidget {
  const _SmallService({required this.icon, required this.title, required this.onTap});
  final IconData icon; final String title; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Column(children: [
      CircleAvatar(radius: 25, backgroundColor: Colors.white, child: Icon(icon, color: _ink, size: 24)),
      const SizedBox(height: 7),
      Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _ink)),
    ]),
  );
}

class _AddressRow extends StatelessWidget {
  const _AddressRow({required this.icon, required this.title, required this.onTap});
  final IconData icon; final String title; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero, leading: Icon(icon, color: _muted),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: _ink)),
    trailing: const Icon(Icons.chevron_right_rounded, color: _muted),
    onTap: onTap,
  );
}

class IntercityPage extends StatefulWidget {
  const IntercityPage({super.key});
  @override
  State<IntercityPage> createState() => _IntercityPageState();
}

class _IntercityPageState extends State<IntercityPage> {
  final _destination = TextEditingController();
  int _seats = 1;
  String _tripType = 'Место в машине';
  @override
  void dispose() { _destination.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _page,
    appBar: AppBar(title: const Text('Межгород', style: TextStyle(fontWeight: FontWeight.w900)), backgroundColor: _surface, foregroundColor: _ink, elevation: 0),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      const Text('Куда поедем?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _ink)),
      const SizedBox(height: 16),
      const TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.trip_origin), labelText: 'Откуда', hintText: 'Шымкент'), readOnly: true),
      const SizedBox(height: 10),
      TextField(controller: _destination, decoration: const InputDecoration(prefixIcon: Icon(Icons.location_on), labelText: 'Куда', hintText: 'Введите город')),
      const SizedBox(height: 20),
      Card(color: _surface, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFEDEDE8))), child: Column(children: [
        RadioListTile<String>(value: 'Место в машине', groupValue: _tripType, onChanged: (v) => setState(() => _tripType = v ?? 'Место в машине'), title: const Text('С попутчиками', style: TextStyle(fontWeight: FontWeight.w900)), subtitle: const Text('Место в машине')),
        Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 12),
        Row(children: [
          const Expanded(child: Text('Количество мест', style: TextStyle(fontWeight: FontWeight.w700))),
          IconButton(onPressed: _seats > 1 ? () => setState(() => _seats--) : null, icon: const Icon(Icons.remove_circle_outline)),
          Text('$_seats', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          IconButton(onPressed: _seats < 4 ? () => setState(() => _seats++) : null, icon: const Icon(Icons.add_circle_outline)),
        ]),
        const Text('Цена будет рассчитана по маршруту', style: TextStyle(color: _muted, fontSize: 12)),
      ])),
      ])),
      Card(color: _surface, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFEDEDE8))), child: RadioListTile<String>(
        value: 'Весь салон', groupValue: _tripType, onChanged: (v) => setState(() => _tripType = v ?? 'Место в машине'),
        title: const Text('Весь салон', style: TextStyle(fontWeight: FontWeight.w900)),
        subtitle: const Text('Отдельная машина для вашей поездки • цена рассчитывается по маршруту'),
      )),
      const SizedBox(height: 16),
      SizedBox(height: 56, child: FilledButton(
        style: FilledButton.styleFrom(backgroundColor: _gold, foregroundColor: _ink),
        onPressed: () {
          if (_destination.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Укажите город назначения')));
            return;
          }
          Navigator.push(context, MaterialPageRoute(builder: (_) => PassengerMapPage(initialService: JibekServiceType.intercity)));
        },
        child: const Text('Продолжить', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
      )),
    ]),
  );
}
