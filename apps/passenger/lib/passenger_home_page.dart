import 'package:flutter/material.dart';
import 'package:jibek_shared/jibek_shared.dart';
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
            IconButton(onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu_rounded, size: 28)),
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
      _drawerItem(context, Icons.receipt_long_rounded, 'Мои поездки', () => _showInfo(context, 'История поездок')),
      _drawerItem(context, Icons.favorite_border_rounded, 'Избранные адреса', () => _showInfo(context, 'Избранные адреса')),
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

class PassengerProfilePage extends StatelessWidget {
  const PassengerProfilePage({super.key});

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
      _profileItem(Icons.receipt_long_rounded, 'Мои поездки'),
      _profileItem(Icons.favorite_border_rounded, 'Избранные адреса'),
      _profileItem(Icons.credit_card_rounded, 'Способы оплаты'),
      _profileItem(Icons.notifications_none_rounded, 'Уведомления'),
      _profileItem(Icons.help_outline_rounded, 'Поддержка'),
      _profileItem(Icons.info_outline_rounded, 'О приложении'),
    ]),
  );

  Widget _profileItem(IconData icon, String title) => Card(
    color: _surface, elevation: 0, margin: const EdgeInsets.only(bottom: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ListTile(leading: Icon(icon, color: _ink), title: Text(title, style: const TextStyle(color: _ink, fontWeight: FontWeight.w700)), trailing: const Icon(Icons.chevron_right_rounded, color: _muted), onTap: () {}),
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
