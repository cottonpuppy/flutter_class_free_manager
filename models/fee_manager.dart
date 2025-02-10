import 'package:flutter/foundation.dart';
import 'record.dart';

class FeeManager extends ChangeNotifier {
  final List<Record> _records = []; // Active records
  final List<Record> _archivedRecords = []; // Archived records
  double _remainingBalance = 800.0;

  // Getters
  List<Record> get records => List.unmodifiable(_records);
  List<Record> get archivedRecords => List.unmodifiable(_archivedRecords);
  double get remainingBalance => _remainingBalance;

  // Add a new record and update balance
  void addRecord(Record record) {
    if (_remainingBalance < record.amount) {
      throw Exception("Insufficient balance to add the record.");
    }
    _records.add(record);
    _remainingBalance -= record.amount;
    notifyListeners();
  }

  // Collect fees and update balance
  void collectFee(double amount) {
    _remainingBalance += amount;
    notifyListeners();
  }

  // Archive eligible records (isConfirmed = true && isReviewed = true)
  void archiveEligibleRecords() {
    final eligibleRecords = _records.where((record) => record.isConfirmed && record.isReviewed).toList();
    for (final record in eligibleRecords) {
      _records.remove(record); // Remove from active records
      _archivedRecords.add(record); // Add to archived records
    }
    notifyListeners();
  }

  // Unarchive a record
  void unarchiveRecord(Record record) {
    _archivedRecords.remove(record);
    _records.add(record);
    notifyListeners();
  }

  // Reset balance (optional utility function)
  void resetBalance(double newBalance) {
    _remainingBalance = newBalance;
    notifyListeners();
  }
}
