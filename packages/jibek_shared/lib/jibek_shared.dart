// ignore_for_file: deprecated_member_use

library jibek_shared;

import 'package:flutter/material.dart';

export 'order_models.dart';
export 'order_repository.dart';

class JibekTheme {
  static const navy = Color(0xFF071B45);
  static const blue = Color(0xFF123B82);
  static const gold = Color(0xFFE5B43C);
  static const goldLight = Color(0xFFFFE7A0);
  static const paper = Color(0xFFF3F6FC);
  static const ink = Color(0xFF10254D);
  static const muted = Color(0xFF687895);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: navy,
      brightness: Brightness.light,
      primary: navy,
      secondary: gold,
      surface: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: paper,
      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.w900,
          letterSpacing: .5,
        ),
        iconTheme: IconThemeData(color: goldLight),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1.5,
        shadowColor: navy.withOpacity(.07),
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFFE7ECF5)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE8EDF5),
        thickness: 1,
        space: 1,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: ink, fontSize: 28, fontWeight: FontWeight.w900, height: 1.12),
        headlineMedium: TextStyle(color: ink, fontSize: 23, fontWeight: FontWeight.w900, height: 1.15),
        titleLarge: TextStyle(color: ink, fontSize: 19, fontWeight: FontWeight.w800),
        titleMedium: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800),
        bodyLarge: TextStyle(color: ink, fontSize: 15, height: 1.4),
        bodyMedium: TextStyle(color: muted, fontSize: 13, height: 1.4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF7F9FD),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: Color(0xFF8A98B2)),
        labelStyle: const TextStyle(color: muted, fontWeight: FontWeight.w600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Color(0xFFE4EAF4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: gold, width: 1.7),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFB9C3D4),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: navy,
          side: const BorderSide(color: gold, width: 1.25),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: blue,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF1F4FA),
        selectedColor: goldLight,
        disabledColor: const Color(0xFFE9EDF4),
        side: const BorderSide(color: Color(0xFFE0E6F0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        labelStyle: const TextStyle(color: ink, fontWeight: FontWeight.w700),
        secondaryLabelStyle: const TextStyle(color: navy, fontWeight: FontWeight.w800),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navy,
        indicatorColor: const Color(0xFF294C88),
        elevation: 8,
        iconTheme: WidgetStateProperty.resolveWith((states) =>
          IconThemeData(color: states.contains(WidgetState.selected) ? goldLight : Colors.white70)),
        labelTextStyle: WidgetStateProperty.resolveWith((states) =>
          TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: states.contains(WidgetState.selected) ? goldLight : Colors.white70)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: navy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class JibekHomeShell extends StatelessWidget {
  const JibekHomeShell({
    required this.title,
    required this.subtitle,
    required this.roleLabel,
    required this.children,
    super.key,
  });

  final String title;
  final String subtitle;
  final String roleLabel;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            Text(roleLabel, style: const TextStyle(
              color: JibekTheme.goldLight, fontSize: 10, letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            )),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Профиль',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Профиль добавим следующим модулем')),
            ),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
          children: [
            Text(subtitle, style: const TextStyle(color: JibekTheme.muted, fontSize: 15)),
            const SizedBox(height: 22),
            ...children,
          ],
        ),
      ),
    );
  }
}

class JibekServiceTile extends StatelessWidget {
  const JibekServiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF2C9), Color(0xFFFFE3A0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: const Color(0xFFE9C76D)),
                ),
                child: Icon(icon, color: JibekTheme.navy, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w900, color: JibekTheme.ink,
                    )),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(
                      fontSize: 13, color: JibekTheme.muted, height: 1.35,
                    )),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: JibekTheme.gold),
            ],
          ),
        ),
      ),
    );
  }
}
