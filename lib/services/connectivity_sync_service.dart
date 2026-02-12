// import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import '../controllers/profit_controller.dart';
// import 'firebase_sync_service.dart';

// class ConnectivitySyncService {
//   final _connectivity = Connectivity();
//   StreamSubscription? _sub;

//   void start(ProfitController controller) {
//     _sub = _connectivity.onConnectivityChanged.listen((result) {
//       if (result != ConnectivityResult.none) {
//         FirebaseProfitSyncService().syncAll(controller);
//       }
//     });
//   }

//   void dispose() {
//     _sub?.cancel();
//   }
// }

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../controllers/profit_controller.dart';
import '../controllers/transaction_controller.dart';
import 'firebase_sync_service.dart';

class ConnectivitySyncService {
  final _connectivity = Connectivity();
  StreamSubscription? _sub;

  void start(
    ProfitController profitController,
    TransactionController transactionController,
  ) {
    _sub = _connectivity.onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none) {
        try {
          await FirebaseSyncService().syncAll(
            transactionController,
            profitController,
          );
        } catch (_) {
          // silently ignore auto-sync errors
        }
      }
    });
  }

  void dispose() {
    _sub?.cancel();
  }
}
