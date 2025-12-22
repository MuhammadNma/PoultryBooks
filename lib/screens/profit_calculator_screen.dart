import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../controllers/input_controllers.dart';
import '../controllers/profit_controller.dart';
import '../models/profit_record.dart';
import '../utils/calculator.dart';

import '../widgets/number_field.dart';
import '../widgets/result_card.dart';
import '../widgets/saved_profit_card_expandable.dart';

import '../screens/calendar_profit_view.dart';

class ProfitCalculatorScreen extends StatefulWidget {
  const ProfitCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<ProfitCalculatorScreen> createState() => _ProfitCalculatorScreenState();
}

class _ProfitCalculatorScreenState extends State<ProfitCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final inputs = InputControllers();
  final profitController = ProfitController();

  bool showAdvanced = false;
  bool showOtherCosts = false;
  bool _isInitialized = false;
  bool _hasCalculated = false;

  double profit = 0;
  double eggIncome = 0;
  double feedCost = 0;
  double fixedCostPerDay = 0;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    await profitController.init();
    setState(() => _isInitialized = true);
  }

  double _parse(String text) =>
      double.tryParse(text.replaceAll(',', '').trim()) ?? 0;

  void _calculate() {
    final crates = _parse(inputs.crates.text);
    final cratePrice = _parse(inputs.cratePrice.text);
    final eggPieces = _parse(inputs.eggPieces.text);

    final feedBagCost = _parse(inputs.feedBagCost.text);
    final feedBagSize = _parse(inputs.feedBagSize.text);
    final feedEaten = _parse(inputs.feedEaten.text);

    final medication = _parse(inputs.medication.text);
    final supplements = _parse(inputs.supplements.text);
    final electricity = _parse(inputs.electricity.text);
    final water = _parse(inputs.water.text);
    final labor = _parse(inputs.labor.text);
    final packaging = _parse(inputs.packaging.text);
    final transport = _parse(inputs.transport.text);

    final numberOfBirds = _parse(inputs.numberOfBirds.text).round();
    final costPerBird = _parse(inputs.costPerBird.text);
    final layingPeriod = _parse(inputs.layingPeriodDays.text).round();
    final housingCost = _parse(inputs.housingCost.text);
    final housingLifespan = _parse(inputs.housingLifespan.text).round();
    final equipmentCost = _parse(inputs.equipmentCost.text);
    final equipmentLifespan = _parse(inputs.equipmentLifespan.text).round();
    final mortalityCost = _parse(inputs.mortalityCost.text);

    final result = Calculator.calculateDailyProfit(
      crates: crates,
      cratePrice: cratePrice,
      eggPieces: eggPieces,
      feedBagCost: feedBagCost,
      feedBagSizeKg: feedBagSize,
      feedEatenKg: feedEaten,
      medication: medication,
      supplements: supplements,
      electricity: electricity,
      water: water,
      labor: labor,
      packaging: packaging,
      transport: transport,
      numberOfBirds: numberOfBirds,
      costPerBird: costPerBird,
      layingPeriodDays: layingPeriod,
      housingCost: housingCost,
      housingLifespanDays: housingLifespan,
      equipmentCost: equipmentCost,
      equipmentLifespanDays: equipmentLifespan,
      mortalityCost: mortalityCost,
    );

    final singleEgg = Calculator.singleEggPrice(cratePrice);
    final income = (crates * cratePrice) + (eggPieces * singleEgg);

    final feedCostCalc =
        feedBagSize <= 0 ? 0 : (feedBagCost / feedBagSize) * feedEaten;

    final fixedCost = ((numberOfBirds * costPerBird) /
            (layingPeriod > 0 ? layingPeriod : 1)) +
        (housingLifespan > 0 ? housingCost / housingLifespan : 0) +
        (equipmentLifespan > 0 ? equipmentCost / equipmentLifespan : 0);

    setState(() {
      profit = result;
      eggIncome = income;
      feedCost = feedCostCalc.toDouble();
      fixedCostPerDay = fixedCost;
      _hasCalculated = true;
    });
  }

  Future<void> _save() async {
    final record = ProfitRecord(
      date: DateTime.now(),
      profit: profit,
      eggIncome: eggIncome,
      feedCost: feedCost,
      fixedCostPerDay: fixedCostPerDay,
    );

    if (profitController.isSavedForToday(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Today's profit has already been saved.")),
      );
      return;
    }

    await profitController.addRecord(record);
    setState(() {});
  }

  @override
  void dispose() {
    inputs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final records = profitController.records;
    final previewRecords = records.take(5).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Profit Calculator')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// INPUT FORM
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    NumberField(
                        controller: inputs.crates, label: 'Crates Produced'),
                    NumberField(
                        controller: inputs.cratePrice,
                        label: 'Price per Crate',
                        prefixText: '₦'),
                    NumberField(
                        controller: inputs.eggPieces, label: 'Egg Pieces'),
                    NumberField(
                        controller: inputs.feedBagCost,
                        label: 'Feed Bag Cost',
                        prefixText: '₦'),
                    NumberField(
                        controller: inputs.feedBagSize, label: 'Bag Size (kg)'),
                    NumberField(
                        controller: inputs.feedEaten, label: 'Feed Eaten (kg)'),
                    Row(
                      children: [
                        Checkbox(
                          value: showOtherCosts,
                          onChanged: (v) =>
                              setState(() => showOtherCosts = v ?? false),
                        ),
                        const Text('Show Other Costs'),
                      ],
                    ),
                    if (showOtherCosts) ...[
                      NumberField(
                          controller: inputs.medication,
                          label: 'Medication',
                          prefixText: '₦'),
                      NumberField(
                          controller: inputs.supplements,
                          label: 'Supplements',
                          prefixText: '₦'),
                      NumberField(
                          controller: inputs.electricity,
                          label: 'Electricity',
                          prefixText: '₦'),
                      NumberField(
                          controller: inputs.water,
                          label: 'Water',
                          prefixText: '₦'),
                      NumberField(
                          controller: inputs.labor,
                          label: 'Labor',
                          prefixText: '₦'),
                      NumberField(
                          controller: inputs.packaging,
                          label: 'Packaging',
                          prefixText: '₦'),
                      NumberField(
                          controller: inputs.transport,
                          label: 'Transport',
                          prefixText: '₦'),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: _calculate,
                          child: const Text('Calculate'),
                        ),
                        ElevatedButton(
                          onPressed: _save,
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// RESULT
              if (_hasCalculated)
                Center(
                  child: ResultCard(
                    eggIncome: eggIncome,
                    feedCost: feedCost,
                    fixedCostPerDay: fixedCostPerDay,
                    profit: profit,
                  ),
                ),

              const SizedBox(height: 24),

              /// SAVED RECORDS (MAX 5)
              ...previewRecords.map(
                (record) => SavedProfitCardExpandable(
                  record: record,
                  profitController: profitController,
                  onDeleted: () => setState(() {}),
                ),
              ),

              /// VIEW MORE (ALWAYS SHOWN)
              Center(
                child: TextButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CalendarProfitView(
                          controller: profitController,
                        ),
                      ),
                    );
                    setState(() {}); // refresh after returning
                  },
                  child: const Text(
                    'View More',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
