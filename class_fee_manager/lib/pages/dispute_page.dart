import 'package:flutter/material.dart';
import '../models/record.dart';

class DisputePage extends StatefulWidget {
  final Record record;

  DisputePage({required this.record});

  @override
  _DisputePageState createState() => _DisputePageState();
}

class _DisputePageState extends State<DisputePage> {
  final TextEditingController _disputeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dispute Record'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Item: ${widget.record.item}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            TextField(
              controller: _disputeController,
              decoration: InputDecoration(labelText: 'Enter Your Dispute'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_disputeController.text.isNotEmpty) {
                  setState(() {
                    widget.record.disputes.add(_disputeController.text);
                    _disputeController.clear();
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Submit Dispute'),
            ),
          ],
        ),
      ),
    );
  }
}
