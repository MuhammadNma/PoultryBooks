import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../controllers/transaction_controller.dart';
import '../../models/customer.dart';
import '../../widgets/customer_summary_tiles.dart';
import '../../widgets/customer_tile.dart';
import 'customer_details_screen.dart';
import 'add_customer_screen.dart';

class CustomersScreen extends StatefulWidget {
  final TransactionController txController;

  const CustomersScreen({
    Key? key,
    required this.txController,
  }) : super(key: key);

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  void _addCustomer() async {
    final newCustomer = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddCustomerScreen(),
      ),
    );

    if (newCustomer is Customer) {
      widget.txController.addCustomer(newCustomer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customers"),
      ),
      body: ValueListenableBuilder<Box<Customer>>(
        valueListenable: widget.txController.customersBox.listenable(),
        builder: (context, box, _) {
          final customers = box.values.toList();

          return Column(
            children: [
              if (customers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: CustomerSummaryTiles(
                    txController: widget.txController,
                  ),
                ),
              Expanded(
                child: customers.isEmpty
                    ? const Center(
                        child: Text(
                          "No customers yet.\nAdd customers to start tracking.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          final customer = customers[index];

                          return CustomerTile(
                            customer: customer,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CustomerDetailsScreen(
                                    customer: customer,
                                    txController: widget.txController,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCustomer,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
