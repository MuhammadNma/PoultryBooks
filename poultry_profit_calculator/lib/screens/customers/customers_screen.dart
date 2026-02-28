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
    super.key,
    required this.txController,
  });

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Customers",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ValueListenableBuilder<Box<Customer>>(
        valueListenable: widget.txController.customersBox.listenable(),
        builder: (context, box, _) {
          final customers = box.values.toList();

          final filteredCustomers = customers.where((c) {
            final name = c.name.toLowerCase();
            return name.contains(_searchQuery.toLowerCase());
          }).toList();

          return Column(
            children: [
              /// SUMMARY SECTION
              if (customers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: CustomerSummaryTiles(
                    txController: widget.txController,
                  ),
                ),

              /// SEARCH BAR
              if (customers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search customers...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              /// CUSTOMER LIST
              Expanded(
                child: customers.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = filteredCustomers[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              elevation: 1,
                              child: CustomerTile(
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
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),

      /// MODERN FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCustomer,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text("Add Customer"),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "No customers yet",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Add customers to start tracking their transactions and balances.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            // const SizedBox(height: 20),
            // ElevatedButton.icon(
            //   onPressed: _addCustomer,
            //   icon: const Icon(Icons.person_add),
            //   label: const Text("Add First Customer"),
            // )
          ],
        ),
      ),
    );
  }
}
