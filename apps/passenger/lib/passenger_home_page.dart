import 'package:flutter/material.dart';
import 'package:jibek_shared/jibek_shared.dart';
import 'main.dart';

const _ink = Color(0xFF17212B);
const _gold = Color(0xFFFFD400);
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
    backgroundColor: const Color(0xFFF5F6F8),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
        children: [
          Row(children: [
            IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Меню Bake Taxi'))),
              icon: const Icon(Icons.menu_rounded, size: 28)),
            const Spacer(),
            const Text('BAKE TAXI', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: _ink)),
            const Spacer(),
            IconButton(onPressed: () {}, icon: const Icon(Icons.account_circle_outlined, size: 28)),
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
              _ServiceCard(title: 'Такси', subtitle: 'от 4 мин', icon: Icons.local_taxi_rounded, color: const Color(0xFFFFE68A), onTap: () => _open(context, JibekServiceType.cityTaxi)),
              _ServiceCard(title: 'Доставка', subtitle: 'Посылка', icon: Icons.inventory_2_rounded, color: const Color(0xFFDCEBFF), onTap: () => _open(context, JibekServiceType.parcel)),
              _ServiceCard(title: 'Межгород', subtitle: 'В другой город', icon: Icons.route_rounded, color: const Color(0xFFE8DDFB), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IntercityPage()))),
              _ServiceCard(title: 'Грузовой', subtitle: 'Перевозка вещей', icon: Icons.local_shipping_rounded, color: const Color(0xFFDDF2E4), onTap: () => _open(context, JibekServiceType.freight)),
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

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white, borderRadius: BorderRadius.circular(22),
    child: InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: _ink, size: 27)),
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
    backgroundColor: const Color(0xFFF5F6F8),
    appBar: AppBar(title: const Text('Межгород'), backgroundColor: Colors.white, foregroundColor: _ink),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      const Text('Куда поедем?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _ink)),
      const SizedBox(height: 16),
      const TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.trip_origin), labelText: 'Откуда', hintText: 'Шымкент'), readOnly: true),
      const SizedBox(height: 10),
      TextField(controller: _destination, decoration: const InputDecoration(prefixIcon: Icon(Icons.location_on), labelText: 'Куда', hintText: 'Введите город')),
      const SizedBox(height: 20),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('С попутчиками', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const Text('Место в машине', style: TextStyle(color: _muted)),
        const SizedBox(height: 12),
        Row(children: [
          const Expanded(child: Text('Количество мест', style: TextStyle(fontWeight: FontWeight.w700))),
          IconButton(onPressed: _seats > 1 ? () => setState(() => _seats--) : null, icon: const Icon(Icons.remove_circle_outline)),
          Text('$_seats', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          IconButton(onPressed: _seats < 4 ? () => setState(() => _seats++) : null, icon: const Icon(Icons.add_circle_outline)),
        ]),
        const Text('Цена будет рассчитана по маршруту', style: TextStyle(color: _muted, fontSize: 12)),
      ]))),
      Card(child: RadioListTile<String>(
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
