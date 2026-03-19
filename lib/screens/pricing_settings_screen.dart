import 'package:flutter/material.dart';
import '../controllers/settings_controller.dart';
import '../models/app_settings.dart';

class PricingSettingsScreen extends StatefulWidget {
  final SettingsController controller;

  const PricingSettingsScreen({
    super.key,
    required this.controller,
  });

  @override
  State<PricingSettingsScreen> createState() => _PricingSettingsScreenState();
}

class _PricingSettingsScreenState extends State<PricingSettingsScreen> {
  late TextEditingController crateCtrl;
  late TextEditingController feedCtrl;
  late TextEditingController bagCtrl;

  bool saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.controller.settings;

    crateCtrl = TextEditingController(text: s.pricePerCrate.toString());
    feedCtrl = TextEditingController(text: s.feedBagCost.toString());
    bagCtrl = TextEditingController(text: s.bagSizeKg.toString());
  }

  Future<void> _save() async {
    setState(() => saving = true);

    final updated = AppSettings(
      pricePerCrate: double.tryParse(crateCtrl.text) ?? 0,
      feedBagCost: double.tryParse(feedCtrl.text) ?? 0,
      bagSizeKg: double.tryParse(bagCtrl.text) ?? 25,
      farmName: '',
    );

    await widget.controller.save(updated);

    if (mounted) {
      setState(() => saving = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pricing Defaults')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionCard(
            title: 'Egg Sales',
            child: _field(
              controller: crateCtrl,
              label: 'Price per crate',
              prefix: '₦ ',
              icon: Icons.egg_alt,
            ),
          ),
          const SizedBox(height: 16),
          _sectionCard(
            title: 'Feed Cost',
            child: _field(
              controller: feedCtrl,
              label: 'Feed bag cost',
              prefix: '₦ ',
              icon: Icons.agriculture,
            ),
          ),
          const SizedBox(height: 16),
          _sectionCard(
            title: 'Bag Size',
            child: _field(
              controller: bagCtrl,
              label: 'Bag size (kg)',
              suffix: 'kg',
              icon: Icons.scale,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: saving ? null : _save,
            child: saving
                ? const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  )
                : const Text('Save Changes'),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? prefix,
    String? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        prefixText: prefix,
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
