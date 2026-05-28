// lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/settings_provider.dart';
import '../../core/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _farmCtrl;
  late TextEditingController _priceCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsProvider>().settings;
    _farmCtrl = TextEditingController(text: s.farmName);
    _priceCtrl = TextEditingController(
        text: s.defaultPricePerCrate > 0
            ? s.defaultPricePerCrate.toStringAsFixed(0)
            : '');
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final s = context.read<SettingsProvider>().settings;
    await context.read<SettingsProvider>().save(s.copyWith(
          farmName:
              _farmCtrl.text.trim().isEmpty ? 'My Farm' : _farmCtrl.text.trim(),
          defaultPricePerCrate: double.tryParse(_priceCtrl.text) ?? 0,
        ));
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Settings saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Account
        _SectionLabel('Account'),
        Card(
            child: Column(children: [
          ListTile(
            leading: const Icon(Icons.person_outlined),
            title: Text(user?.email ?? 'Not signed in'),
            subtitle: const Text('Logged in as'),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () async => await FirebaseAuth.instance.signOut(),
          ),
        ])),
        const SizedBox(height: 20),

        // Farm Settings
        _SectionLabel('Farm Settings'),
        Card(
            child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            TextField(
                controller: _farmCtrl,
                decoration: const InputDecoration(
                    labelText: 'Farm Name',
                    prefixIcon: Icon(Icons.home_work_outlined))),
            const SizedBox(height: 14),
            TextField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Default Price per Crate (₦)',
                  prefixIcon: Icon(Icons.sell_outlined),
                  hintText: 'e.g. 1800',
                )),
            const SizedBox(height: 16),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Save Settings'),
                )),
          ]),
        )),
        const SizedBox(height: 80),
      ]),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel(this.title);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(title,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600)),
      );
}
