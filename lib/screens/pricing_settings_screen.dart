import 'package:flutter/material.dart';
import '../controllers/settings_controller.dart';
import '../models/app_settings.dart';

class PricingSettingsScreen extends StatefulWidget {
  final SettingsController controller;

  const PricingSettingsScreen({super.key, required this.controller});

  @override
  State<PricingSettingsScreen> createState() => _PricingSettingsScreenState();
}

class _PricingSettingsScreenState extends State<PricingSettingsScreen> {
  late TextEditingController crateCtrl;
  late TextEditingController feedCtrl;
  late TextEditingController bagCtrl;

  @override
  void initState() {
    super.initState();
    final s = widget.controller.settings;
    crateCtrl = TextEditingController(text: s.pricePerCrate.toString());
    feedCtrl = TextEditingController(text: s.feedBagCost.toString());
    bagCtrl = TextEditingController(text: s.bagSizeKg.toString());
  }

  void _save() async {
    await widget.controller.save(
      AppSettings(
        pricePerCrate: double.tryParse(crateCtrl.text) ?? 0,
        feedBagCost: double.tryParse(feedCtrl.text) ?? 0,
        bagSizeKg: double.tryParse(bagCtrl.text) ?? 25,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pricing Defaults')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: crateCtrl,
              decoration: const InputDecoration(labelText: 'Price per crate'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: feedCtrl,
              decoration: const InputDecoration(labelText: 'Feed bag cost'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: bagCtrl,
              decoration: const InputDecoration(labelText: 'Bag size (kg)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
