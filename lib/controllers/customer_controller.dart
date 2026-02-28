import '../models/customer.dart';

class CustomerController {
  final List<Customer> _customers = [];

  List<Customer> get customers => List.unmodifiable(_customers);

  void addCustomer(Customer c) {
    _customers.add(c);
  }

  void deleteCustomer(String id) {
    _customers.removeWhere((c) => c.id == id);
  }

  Customer? findById(String id) =>
      // ignore: cast_from_null_always_fails
      _customers.firstWhere((c) => c.id == id, orElse: () => null as Customer);
}
