import 'package:flutter/material.dart';

class CollectFeePage extends StatefulWidget {
  final double currentBalance;
  final Function(double) onFeeCollected;

  CollectFeePage({required this.currentBalance, required this.onFeeCollected});

  @override
  _CollectFeePageState createState() => _CollectFeePageState();
}

class _CollectFeePageState extends State<CollectFeePage> {
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collect Class Fee'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Current Balance: \$${widget.currentBalance.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount to Add'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(_amountController.text);
                  if (amount != null && amount > 0) {
                    widget.onFeeCollected(amount);
                    Navigator.pop(context);
                  } else {
                    _showInvalidAmountAlert();
                  }
                },
                child: Text('Add Fee'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInvalidAmountAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invalid Amount'),
        content: Text('Please enter a valid amount greater than 0.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
