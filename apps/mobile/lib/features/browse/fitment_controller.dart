import 'package:flutter/foundation.dart';

import 'models.dart';

/// Session-scoped "customer's bike" selection, one per machine. Not persisted:
/// a clerk serves one customer at a time, so the pick shouldn't outlive the
/// app session and silently filter the next customer's lookup.
class FitmentController extends ChangeNotifier {
  final _byMachine = <String, Fitment>{};

  Fitment fitmentFor(String machineId) => _byMachine[machineId] ?? const Fitment();

  void set(String machineId, Fitment fitment) {
    if (fitment.isActive) {
      _byMachine[machineId] = fitment;
    } else {
      _byMachine.remove(machineId);
    }
    notifyListeners();
  }

  void clear(String machineId) => set(machineId, const Fitment());
}
