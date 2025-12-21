import 'package:flutter/material.dart';
import '../../controllers/transaction_controller.dart';
import '../../utils/currency.dart';
import '../../widgets/customer_summary_tiles.dart';
import 'customer_details_screen.dart';
import 'add_customer_screen.dart';
import '../../models/customer.dart';

class CustomersScreen extends StatefulWidget {
  final TransactionController txController;

  const CustomersScreen({Key? key, required this.txController})
      : super(key: key);

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  void _addCustomer() async {
    final newCustomer = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
    );

    if (newCustomer is Customer) {
      setState(() {
        widget.txController.addCustomer(newCustomer);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final customers = widget.txController.customers;

    return Scaffold(
      appBar: AppBar(title: const Text("Customers")),
      body: Column(
        children: [
          if (customers.isNotEmpty)
            CustomerSummaryTiles(txController: widget.txController),
          const Divider(),
          Expanded(
            child: customers.isEmpty
                ? const Center(
                    child: Text(
                      "No Customers yet.\nAdd customers to start tracking.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final c = customers[index];
                      return ListTile(
                        title: Text(c.name),
                        subtitle: Text(
                          "Balance: ${formatMoney(c.balance)} | "
                          "Paid: ${formatMoney(c.totalPaid)} | "
                          "Spent: ${formatMoney(c.totalSpent)}",
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CustomerDetailsScreen(
                                  customer: c,
                                  txController: widget.txController),
                            ),
                          ).then((_) => setState(() {}));
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCustomer,
        child: const Icon(Icons.person_add),
        tooltip: "Add Customer",
      ),
    );
  }
}
