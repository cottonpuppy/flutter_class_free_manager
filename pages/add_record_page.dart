import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/record.dart';

class AddRecordPage extends StatefulWidget {
  @override
  _AddRecordPageState createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _verifierController = TextEditingController();
  File? _receiptImage;
  File? _productImage;

  Future<void> _pickImage(bool isProductImage) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        if (isProductImage) {
          _productImage = File(pickedFile.path);
        } else {
          _receiptImage = File(pickedFile.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Record'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _itemController,
              decoration: InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _verifierController,
              decoration: InputDecoration(labelText: 'Monitor'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _pickImage(false),
              child: Text('Take Receipt Photo'),
            ),
            _receiptImage != null
                ? Image.file(_receiptImage!, height: 100)
                : Text('No Receipt Image Selected'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _pickImage(true),
              child: Text('Take Product Photo'),
            ),
            _productImage != null
                ? Image.file(_productImage!, height: 200)
                : Text('No Product Image Selected'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_itemController.text.isNotEmpty &&
                    _amountController.text.isNotEmpty &&
                    _verifierController.text.isNotEmpty) {
                  final newRecord = Record(
                    item: _itemController.text,
                    amount: double.parse(_amountController.text),
                    verifier: _verifierController.text,
                    date: DateTime.now(),
                    receiptImage: _receiptImage,
                    productImage: _productImage,
                  );
                  Navigator.pop(context, newRecord);
                }
              },
              child: Text('Save Record'),
            ),
          ],
        ),
      ),
    );
  }
}
