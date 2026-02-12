// import 'package:flutter/material.dart';

// import '../controllers/input_controllers.dart';
// import '../controllers/profit_controller.dart';
// import '../controllers/settings_controller.dart';
// import '../models/profit_record.dart';
// import '../utils/calculator.dart';

// import '../widgets/number_field.dart';
// import '../widgets/result_card.dart';
// import '../widgets/saved_profit_card_expandable.dart';

// import '../screens/calendar_profit_view.dart';

// class ProfitCalculatorScreen extends StatefulWidget {
//   final DateTime? selectedDate;
//   final ProfitController profitController;
//   final SettingsController settingsController;

//   const ProfitCalculatorScreen({
//     super.key,
//     this.selectedDate,
//     required this.profitController,
//     required this.settingsController,
//   });

//   @override
//   State<ProfitCalculatorScreen> createState() => _ProfitCalculatorScreenState();
// }

// class _ProfitCalculatorScreenState extends State<ProfitCalculatorScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final inputs = InputControllers();
//   bool showOtherCosts = false;
//   bool _hasCalculated = false;

//   double profit = 0;
//   double eggIncome = 0;
//   double feedCost = 0;
//   double fixedCostPerDay = 0;
//   double eggsProduced = 0;

//   @override
//   void initState() {
//     super.initState();
//     _loadDefaults();
//   }

//   /// Load prices from Settings
//   void _loadDefaults() {
//     final s = widget.settingsController.settings;
//     inputs.cratePrice.text = s.pricePerCrate.toString();
//     inputs.feedBagCost.text = s.feedBagCost.toString();
//     inputs.feedBagSize.text = s.bagSizeKg.toString();
//   }

//   double _parse(String text) =>
//       double.tryParse(text.replaceAll(',', '').trim()) ?? 0;

//   void _calculate() {
//     final crates = _parse(inputs.crates.text);
//     final cratePrice = _parse(inputs.cratePrice.text);
//     final eggPieces = _parse(inputs.eggPieces.text);

//     final feedBagCost = _parse(inputs.feedBagCost.text);
//     final feedBagSize = _parse(inputs.feedBagSize.text);
//     final feedEaten = _parse(inputs.feedEaten.text);

//     final medication = _parse(inputs.medication.text);
//     final supplements = _parse(inputs.supplements.text);
//     final electricity = _parse(inputs.electricity.text);
//     final water = _parse(inputs.water.text);
//     final labor = _parse(inputs.labor.text);
//     final packaging = _parse(inputs.packaging.text);
//     final transport = _parse(inputs.transport.text);

//     final numberOfBirds = _parse(inputs.numberOfBirds.text).round();
//     final costPerBird = _parse(inputs.costPerBird.text);
//     final layingPeriod = _parse(inputs.layingPeriodDays.text).round();
//     final housingCost = _parse(inputs.housingCost.text);
//     final housingLifespan = _parse(inputs.housingLifespan.text).round();
//     final equipmentCost = _parse(inputs.equipmentCost.text);
//     final equipmentLifespan = _parse(inputs.equipmentLifespan.text).round();
//     final mortalityCost = _parse(inputs.mortalityCost.text);

//     final result = Calculator.calculateDailyProfit(
//       crates: crates,
//       cratePrice: cratePrice,
//       eggPieces: eggPieces,
//       feedBagCost: feedBagCost,
//       feedBagSizeKg: feedBagSize,
//       feedEatenKg: feedEaten,
//       medication: medication,
//       supplements: supplements,
//       electricity: electricity,
//       water: water,
//       labor: labor,
//       packaging: packaging,
//       transport: transport,
//       numberOfBirds: numberOfBirds,
//       costPerBird: costPerBird,
//       layingPeriodDays: layingPeriod,
//       housingCost: housingCost,
//       housingLifespanDays: housingLifespan,
//       equipmentCost: equipmentCost,
//       equipmentLifespanDays: equipmentLifespan,
//       mortalityCost: mortalityCost,
//     );

//     final singleEgg = Calculator.singleEggPrice(cratePrice);
//     final income = (crates * cratePrice) + (eggPieces * singleEgg);

//     final feedCostCalc =
//         feedBagSize <= 0 ? 0 : (feedBagCost / feedBagSize) * feedEaten;

//     final fixedCost = ((numberOfBirds * costPerBird) /
//             (layingPeriod > 0 ? layingPeriod : 1)) +
//         (housingLifespan > 0 ? housingCost / housingLifespan : 0) +
//         (equipmentLifespan > 0 ? equipmentCost / equipmentLifespan : 0);

//     setState(() {
//       profit = result;
//       eggIncome = income;
//       feedCost = feedCostCalc.toDouble();
//       fixedCostPerDay = fixedCost;
//       _hasCalculated = true;
//     });
//   }

//   Future<void> _save() async {
//     const eggsPerCrate = 30;

//     final eggsProduced = (inputs.crates.text.isEmpty
//             ? 0
//             : int.parse(inputs.crates.text) * eggsPerCrate) +
//         (inputs.eggPieces.text.isEmpty ? 0 : int.parse(inputs.eggPieces.text));

//     final date = widget.selectedDate ?? DateTime.now();

//     if (widget.profitController.isSavedForToday(date)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('A record already exists for this date')),
//       );
//       return;
//     }

//     final record = ProfitRecord(
//       date: date,
//       profit: profit,
//       eggIncome: eggIncome,
//       feedCost: feedCost,
//       fixedCostPerDay: fixedCostPerDay,
//       eggsProduced: eggsProduced.toInt(),
//     );

//     await widget.profitController.addRecord(record);

//     if (widget.selectedDate != null) {
//       // Opened from calendar → safe to pop
//       Navigator.pop(context);
//     } else {
//       // Opened as bottom tab → just reset calculator
//       inputs.clear();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Profit saved successfully')),
//       );

//       setState(() {
//         _hasCalculated = false;
//         profit = 0;
//         eggIncome = 0;
//         feedCost = 0;
//         fixedCostPerDay = 0;
//       });
//     }
//   }

//   Future<void> _refreshPrices() async {
//     await widget.settingsController.init(); // reload from Hive
//     _loadDefaults(); // update text fields
//     setState(() {});
//   }

//   @override
//   void dispose() {
//     inputs.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final records = widget.profitController.records
//       ..sort((a, b) => b.date.compareTo(a.date));

//     final previewRecords = records.take(5).toList();

//     return Scaffold(
//       appBar: AppBar(title: const Text('Profit Calculator')),
//       body: RefreshIndicator(
//         onRefresh: _refreshPrices,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             children: [
//               Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     NumberField(
//                         controller: inputs.crates, label: 'Crates Produced'),
//                     NumberField(
//                         controller: inputs.eggPieces, label: 'Egg Pieces'),
//                     NumberField(
//                       controller: inputs.cratePrice,
//                       label: 'Price per Crate',
//                       prefixText: '₦',
//                     ),
//                     NumberField(
//                       controller: inputs.feedBagCost,
//                       label: 'Feed Bag Cost',
//                       prefixText: '₦',
//                     ),
//                     NumberField(
//                       controller: inputs.feedBagSize,
//                       label: 'Bag Size (kg)',
//                     ),
//                     NumberField(
//                       controller: inputs.feedEaten,
//                       label: 'Feed Eaten (kg)',
//                     ),
//                     Row(
//                       children: [
//                         Checkbox(
//                           value: showOtherCosts,
//                           onChanged: (v) =>
//                               setState(() => showOtherCosts = v ?? false),
//                         ),
//                         const Text('Show Other Costs'),
//                       ],
//                     ),
//                     if (showOtherCosts) ...[
//                       NumberField(
//                           controller: inputs.medication,
//                           label: 'Medication',
//                           prefixText: '₦'),
//                       NumberField(
//                           controller: inputs.supplements,
//                           label: 'Supplements',
//                           prefixText: '₦'),
//                       NumberField(
//                           controller: inputs.electricity,
//                           label: 'Electricity',
//                           prefixText: '₦'),
//                       NumberField(
//                           controller: inputs.water,
//                           label: 'Water',
//                           prefixText: '₦'),
//                       NumberField(
//                           controller: inputs.labor,
//                           label: 'Labor',
//                           prefixText: '₦'),
//                       NumberField(
//                           controller: inputs.packaging,
//                           label: 'Packaging',
//                           prefixText: '₦'),
//                       NumberField(
//                           controller: inputs.transport,
//                           label: 'Transport',
//                           prefixText: '₦'),
//                     ],
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         ElevatedButton(
//                             onPressed: _calculate,
//                             child: const Text('Calculate')),
//                         ElevatedButton(
//                             onPressed: _save, child: const Text('Save')),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               if (_hasCalculated)
//                 ResultCard(
//                   eggIncome: eggIncome,
//                   feedCost: feedCost,
//                   fixedCostPerDay: fixedCostPerDay,
//                   profit: profit,
//                 ),
//               const SizedBox(height: 20),
//               ...previewRecords.map(
//                 (r) => SavedProfitCardExpandable(
//                   record: r,
//                   profitController: widget.profitController,
//                   onDeleted: () => setState(() {}),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () async {
//                   await Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => CalendarProfitView(
//                         controller: widget.profitController,
//                         settingsController: widget.settingsController,
//                       ),
//                     ),
//                   );
//                   _loadDefaults(); // refresh prices after returning
//                   setState(() {});
//                 },
//                 child: const Text('View More'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../controllers/input_controllers.dart';
import '../controllers/profit_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/profit_record.dart';
import '../utils/calculator.dart';

import '../widgets/number_field.dart';
import '../widgets/result_card.dart';
import '../widgets/saved_profit_card_expandable.dart';

import '../screens/calendar_profit_view.dart';

class ProfitCalculatorScreen extends StatefulWidget {
  final DateTime? selectedDate;
  final ProfitController profitController;
  final SettingsController settingsController;

  const ProfitCalculatorScreen({
    super.key,
    this.selectedDate,
    required this.profitController,
    required this.settingsController,
  });

  @override
  State<ProfitCalculatorScreen> createState() => _ProfitCalculatorScreenState();
}

class _ProfitCalculatorScreenState extends State<ProfitCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final inputs = InputControllers();

  bool showOtherCosts = false;
  bool _hasCalculated = false;

  double profit = 0;
  double eggIncome = 0;
  double feedCost = 0;
  double fixedCostPerDay = 0;

  @override
  void initState() {
    super.initState();
    _loadDefaults();
  }

  void _loadDefaults() {
    final s = widget.settingsController.settings;
    inputs.cratePrice.text = s.pricePerCrate.toString();
    inputs.feedBagCost.text = s.feedBagCost.toString();
    inputs.feedBagSize.text = s.bagSizeKg.toString();
  }

  double _parse(String v) => double.tryParse(v.replaceAll(',', '').trim()) ?? 0;

  // ---------------- CALCULATE ----------------
  void _calculate() {
    final result = Calculator.calculateDailyProfit(
      crates: _parse(inputs.crates.text),
      cratePrice: _parse(inputs.cratePrice.text),
      eggPieces: _parse(inputs.eggPieces.text),
      feedBagCost: _parse(inputs.feedBagCost.text),
      feedBagSizeKg: _parse(inputs.feedBagSize.text),
      feedEatenKg: _parse(inputs.feedEaten.text),
      medication: _parse(inputs.medication.text),
      supplements: _parse(inputs.supplements.text),
      electricity: _parse(inputs.electricity.text),
      water: _parse(inputs.water.text),
      labor: _parse(inputs.labor.text),
      packaging: _parse(inputs.packaging.text),
      transport: _parse(inputs.transport.text),
      numberOfBirds: _parse(inputs.numberOfBirds.text).round(),
      costPerBird: _parse(inputs.costPerBird.text),
      layingPeriodDays: _parse(inputs.layingPeriodDays.text).round(),
      housingCost: _parse(inputs.housingCost.text),
      housingLifespanDays: _parse(inputs.housingLifespan.text).round(),
      equipmentCost: _parse(inputs.equipmentCost.text),
      equipmentLifespanDays: _parse(inputs.equipmentLifespan.text).round(),
      mortalityCost: _parse(inputs.mortalityCost.text),
    );

    final cratePrice = _parse(inputs.cratePrice.text);
    final singleEgg = Calculator.singleEggPrice(cratePrice);
    final income = (_parse(inputs.crates.text) * cratePrice) +
        (_parse(inputs.eggPieces.text) * singleEgg);

    setState(() {
      profit = result;
      eggIncome = income;
      feedCost = _parse(inputs.feedEaten.text) *
          (_parse(inputs.feedBagCost.text) /
              (_parse(inputs.feedBagSize.text) == 0
                  ? 1
                  : _parse(inputs.feedBagSize.text)));
      fixedCostPerDay = result - income + feedCost;
      _hasCalculated = true;
    });
  }

  // ---------------- SAVE ----------------
  Future<void> _save() async {
    final date = widget.selectedDate ?? DateTime.now();

    if (widget.profitController.isSavedForToday(date)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record already exists')),
      );
      return;
    }

    final record = ProfitRecord(
      date: date,
      profit: profit,
      eggIncome: eggIncome,
      feedCost: feedCost,
      fixedCostPerDay: fixedCostPerDay,
      eggsProduced:
          (_parse(inputs.crates.text) * 30 + _parse(inputs.eggPieces.text))
              .toInt(),
    );

    await widget.profitController.addRecord(record);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profit saved')),
    );

    inputs.clear();
    setState(() => _hasCalculated = false);
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final records = widget.profitController.records
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(title: const Text('Profit Calculator')),
      body: RefreshIndicator(
        onRefresh: () async {
          await widget.settingsController.init();
          _loadDefaults();
          setState(() {});
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section('Production'),
            _card([
              NumberField(controller: inputs.crates, label: 'Crates'),
              NumberField(controller: inputs.eggPieces, label: 'Egg Pieces'),
              NumberField(
                controller: inputs.cratePrice,
                label: 'Price per Crate',
                prefixText: '₦',
              ),
            ]),
            _section('Feed'),
            _card([
              NumberField(
                controller: inputs.feedBagCost,
                label: 'Feed Bag Cost',
                prefixText: '₦',
              ),
              NumberField(
                controller: inputs.feedBagSize,
                label: 'Bag Size (kg)',
              ),
              NumberField(
                controller: inputs.feedEaten,
                label: 'Feed Eaten (kg)',
              ),
            ]),
            SwitchListTile(
              value: showOtherCosts,
              onChanged: (v) => setState(() => showOtherCosts = v),
              title: const Text('Include Other Costs'),
            ),
            if (showOtherCosts)
              _card([
                NumberField(
                  controller: inputs.medication,
                  label: 'Medication',
                  prefixText: '₦',
                ),
                NumberField(
                  controller: inputs.supplements,
                  label: 'Supplements',
                  prefixText: '₦',
                ),
                NumberField(
                  controller: inputs.electricity,
                  label: 'Electricity',
                  prefixText: '₦',
                ),
                NumberField(
                  controller: inputs.water,
                  label: 'Water',
                  prefixText: '₦',
                ),
                NumberField(
                  controller: inputs.labor,
                  label: 'Labor',
                  prefixText: '₦',
                ),
                NumberField(
                  controller: inputs.packaging,
                  label: 'Packaging',
                  prefixText: '₦',
                ),
                NumberField(
                  controller: inputs.transport,
                  label: 'Transport',
                  prefixText: '₦',
                ),
              ]),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _calculate,
                    child: const Text('Calculate'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _hasCalculated ? _save : null,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
            if (_hasCalculated) ...[
              const SizedBox(height: 24),
              ResultCard(
                profit: profit,
                eggIncome: eggIncome,
                feedCost: feedCost,
                fixedCostPerDay: fixedCostPerDay,
              ),
            ],
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionHeader('Recent Records'),
                TextButton(
                  onPressed: () => _openCalendar(context),
                  child: const Text('View all'),
                ),
              ],
            ),
            if (records.isEmpty)
              const Center(child: Text('No records yet'))
            else
              ...records.take(5).map(
                    (r) => SavedProfitCardExpandable(
                      record: r,
                      profitController: widget.profitController,
                      onDeleted: () => setState(() {}),
                    ),
                  ),
            // TextButton(
            //   onPressed: () => Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (_) => CalendarProfitView(
            //         controller: widget.profitController,
            //         settingsController: widget.settingsController,
            //       ),
            //     ),
            //   ),
            //   child: const Text('View all records'),
            // ),
          ],
        ),
      ),
    );
  }

  // ---------------- HELPERS ----------------

  Widget _sectionHeader(String text) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      );

  Widget _card(List<Widget> children) => Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: children),
        ),
      );

  @override
  void dispose() {
    inputs.dispose();
    super.dispose();
  }

  void _openCalendar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CalendarProfitView(
          controller: widget.profitController,
          settingsController: widget.settingsController,
        ),
      ),
    );
  }
}
