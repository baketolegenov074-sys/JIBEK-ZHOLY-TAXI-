import 'package:flutter/material.dart';

class DriverProfilePage extends StatelessWidget {
  const DriverProfilePage({super.key});

  static const navy = Color(0xFF10243A);
  static const gold = Color(0xFFFFD400);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text('Профиль'),
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(22)),
            child: const Row(children: [
              CircleAvatar(radius: 31, backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white, size: 34)),
              SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Имя водителя', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('Таксопарк не указан', style: TextStyle(color: Colors.white70)),
              ])),
              Icon(Icons.edit_outlined, color: Colors.white70),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: const [
            Expanded(child: _StatCard(title: 'Рейтинг', value: '4.9', icon: Icons.star_rounded)),
            SizedBox(width: 9),
            Expanded(child: _StatCard(title: 'Уровень', value: 'Мастер', icon: Icons.workspace_premium_outlined)),
            SizedBox(width: 9),
            Expanded(child: _StatCard(title: 'Приоритет', value: '+7', icon: Icons.bolt_rounded)),
          ]),
          const SizedBox(height: 22),
          const _SectionTitle('Настройки'),
          const _ProfileRow(icon: Icons.local_taxi_outlined, title: 'Парк', subtitle: 'Информация о таксопарке'),
          const _ProfileRow(icon: Icons.tune_rounded, title: 'Тарифы и опции', subtitle: 'Выбор доступных заказов'),
          const _ProfileRow(icon: Icons.payments_outlined, title: 'Оплата', subtitle: 'Наличные, карта или Kaspi'),
          const SizedBox(height: 18),
          const _SectionTitle('Мой транспорт'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Марка и модель не указаны', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: navy)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFFF3F5F7), border: Border.all(color: const Color(0xFFCCD2D8)), borderRadius: BorderRadius.circular(9)),
                child: const Center(child: Text('227 AQJ 17', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: 2, color: navy))),
              ),
              const SizedBox(height: 12),
              const Center(child: Icon(Icons.directions_car_filled_rounded, size: 94, color: Color(0xFFCFD5DB))),
              const Center(child: Text('Добавьте данные автомобиля', style: TextStyle(color: Color(0xFF77818B)))),
            ]),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.icon});
  final String title, value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 7),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
    child: Column(children: [
      Icon(icon, color: const Color(0xFFB58A16), size: 21),
      const SizedBox(height: 7),
      Text(value, maxLines: 1, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF10243A))),
      const SizedBox(height: 3),
      Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF77818B))),
    ]),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF10243A))),
  );
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
    child: ListTile(
      leading: Icon(icon, color: const Color(0xFF10243A)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title: раздел будет подключён к данным профиля'))),
    ),
  );
}
