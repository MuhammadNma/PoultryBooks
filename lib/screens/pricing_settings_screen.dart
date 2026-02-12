// import 'package:flutter/material.dart';
// import '../controllers/settings_controller.dart';
// import '../models/app_settings.dart';

// class PricingSettingsScreen extends StatefulWidget {
//   final SettingsController controller;

//   const PricingSettingsScreen({super.key, required this.controller});

//   @override
//   State<PricingSettingsScreen> createState() => _PricingSettingsScreenState();
// }

// class _PricingSettingsScreenState extends State<PricingSettingsScreen> {
//   late TextEditingController crateCtrl;
//   late TextEditingController feedCtrl;
//   late TextEditingController bagCtrl;

//   @override
//   void initState() {
//     super.initState();
//     final s = widget.controller.settings;
//     crateCtrl = TextEditingController(text: s.pricePerCrate.toString());
//     feedCtrl = TextEditingController(text: s.feedBagCost.toString());
//     bagCtrl = TextEditingController(text: s.bagSizeKg.toString());
//   }

//   void _save() async {
//     await widget.controller.save(
//       AppSettings(
//         pricePerCrate: double.tryParse(crateCtrl.text) ?? 0,
//         feedBagCost: double.tryParse(feedCtrl.text) ?? 0,
//         bagSizeKg: double.tryParse(bagCtrl.text) ?? 25,
//       ),
//     );

//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Pricing Defaults')),
//       body: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           children: [
//             TextField(
//               controller: crateCtrl,
//               decoration: const InputDecoration(labelText: 'Price per crate'),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: feedCtrl,
//               decoration: const InputDecoration(labelText: 'Feed bag cost'),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: bagCtrl,
//               decoration: const InputDecoration(labelText: 'Bag size (kg)'),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _save,
//               child: const Text('Save'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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

    await widget.controller.save(
      AppSettings(
        pricePerCrate: double.tryParse(crateCtrl.text) ?? 0,
        feedBagCost: double.tryParse(feedCtrl.text) ?? 0,
        bagSizeKg: double.tryParse(bagCtrl.text) ?? 25,
      ),
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pricing Defaults')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Default Pricing',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'These values are used as defaults when calculating profits.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          _card(
            title: 'Egg Sales',
            child: _field(
              controller: crateCtrl,
              label: 'Price per crate',
              prefix: '₦',
              icon: Icons.egg_alt,
            ),
          ),
          const SizedBox(height: 16),
          _card(
            title: 'Feed Cost',
            child: _field(
              controller: feedCtrl,
              label: 'Feed bag cost',
              prefix: '₦',
              icon: Icons.agriculture,
            ),
          ),
          const SizedBox(height: 16),
          _card(
            title: 'Bag Size',
            child: _field(
              controller: bagCtrl,
              label: 'Bag size',
              suffix: 'kg',
              icon: Icons.scale,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),

      /// ---------- SAVE BUTTON ----------
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          height: 48,
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

  /// ---------------- UI HELPERS ----------------

  Widget _card({required String title, required Widget child}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
      keyboardType: TextInputType.number,
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
