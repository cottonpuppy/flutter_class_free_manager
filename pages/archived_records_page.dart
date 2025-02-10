import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/class_manager.dart';
import '../models/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ArchivedRecordsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final classManager = Provider.of<ClassManager>(context);
    final feeManager = classManager.currentClass.feeManager;

    // Archive eligible records before displaying
    feeManager.archiveEligibleRecords();

    final archivedRecords = feeManager.archivedRecords;

    return Scaffold(
      appBar: AppBar(
        title: Text('Archived Records'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () async {
              if (archivedRecords.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('No archived records available for export!')),
                );
                return;
              }

              // Export archived records to CSV
              await _exportToCSV(archivedRecords);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Archived records exported successfully!')),
              );
            },
          ),
        ],
      ),
      body: archivedRecords.isEmpty
          ? Center(child: Text('No archived records available.'))
          : ListView.builder(
              itemCount: archivedRecords.length,
              itemBuilder: (context, index) {
                final record = archivedRecords[index];
                return ListTile(
                  leading: Icon(Icons.archive, color: Colors.blue),
                  title: Text(record.item),
                  subtitle: Text('Amount: \$${record.amount}'),
                  trailing: IconButton(
                    icon: Icon(Icons.unarchive, color: Colors.green),
                    onPressed: () {
                      feeManager.unarchiveRecord(record); // Unarchive the record
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Record unarchived')),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  // Export records to CSV
  Future<void> _exportToCSV(List<Record> records) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/archived_records.csv';

    final csvData = StringBuffer();
    csvData.writeln('Item,Amount,Date,Verifier'); // Header row

    for (final record in records) {
      csvData.writeln(
          '${record.item},${record.amount},${record.date.toIso8601String()},${record.verifier}');
    }

    final file = File(path);
    await file.writeAsString(csvData.toString());
  }
}
