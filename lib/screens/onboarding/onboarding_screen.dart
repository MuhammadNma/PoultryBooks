// lib/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl  = PageController();
  final _farmCtrl  = TextEditingController(text: 'My Farm');
  final _priceCtrl = TextEditingController();
  int _page = 0;
  bool _saving = false;

  static const _pages = [
    _Page(icon: Icons.agriculture,           title: 'Welcome to PoultryBooks',        subtitle: 'Built for layer farms. Track eggs daily, record sales when they happen, and log expenses as they occur.', color: AppTheme.primary),
    _Page(icon: Icons.egg_outlined,          title: 'Daily Egg Logging',              subtitle: 'Log how many eggs each flock produces every day. Accurate egg counts, not guesswork.', color: Color(0xFF1565C0)),
    _Page(icon: Icons.sell_outlined,         title: 'Record Sales as They Happen',    subtitle: 'When you get an order, record the sale and who paid what. Track who still owes you.', color: Color(0xFF6A1B9A)),
    _Page(icon: Icons.receipt_long_outlined, title: 'Log Expenses Anytime',           subtitle: 'Feed, Fuel, Medication, Salary — log any expense whenever it occurs, not forced into a daily structure.', color: Color(0xFFE65100)),
  ];

  void _next() {
    _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _page++);
  }

  Future<void> _finish() async {
    if (_farmCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter your farm name')));
      return;
    }
    setState(() => _saving = true);
    await context.read<SettingsProvider>().completeOnboarding(
      farmName: _farmCtrl.text.trim(),
      defaultPricePerCrate: double.tryParse(_priceCtrl.text) ?? 0,
    );
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final isSetup = _page >= _pages.length;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length + 1, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _page == i ? 24 : 8, height: 8,
              decoration: BoxDecoration(
                color: _page == i ? AppTheme.primary : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4)),
            )))),
        Expanded(child: PageView(
          controller: _pageCtrl,
          physics: const NeverScrollableScrollPhysics(),
          children: [..._pages.map((p) => _InfoPage(page: p)), _SetupPage(farmCtrl: _farmCtrl, priceCtrl: _priceCtrl)],
        )),
        Padding(padding: const EdgeInsets.all(24),
          child: SizedBox(width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : isSetup ? _finish : _next,
              child: _saving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(isSetup ? 'Get Started' : 'Next')))),
      ])),
    );
  }
}

class _Page {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  const _Page({required this.icon, required this.title, required this.subtitle, required this.color});
}

class _InfoPage extends StatelessWidget {
  final _Page page;
  const _InfoPage({required this.page});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 120, height: 120,
        decoration: BoxDecoration(color: page.color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(page.icon, size: 60, color: page.color)),
      const SizedBox(height: 40),
      Text(page.title, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.3)),
      const SizedBox(height: 16),
      Text(page.subtitle, textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.5)),
    ]),
  );
}

class _SetupPage extends StatelessWidget {
  final TextEditingController farmCtrl, priceCtrl;
  const _SetupPage({required this.farmCtrl, required this.priceCtrl});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 16),
      const Text('Set Up Your Farm', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text('You can change these anytime in Settings.', style: TextStyle(color: Colors.grey.shade600)),
      const SizedBox(height: 28),
      const Text('Farm Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      const SizedBox(height: 8),
      TextField(controller: farmCtrl,
        decoration: const InputDecoration(hintText: 'e.g. Sunrise Farms', prefixIcon: Icon(Icons.home_work_outlined))),
      const SizedBox(height: 20),
      const Text('Default Price per Crate (₦)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      const SizedBox(height: 8),
      TextField(controller: priceCtrl, keyboardType: TextInputType.number,
        decoration: const InputDecoration(hintText: 'e.g. 1800', prefixIcon: Icon(Icons.sell_outlined))),
      const SizedBox(height: 16),
    ]),
  );
}
