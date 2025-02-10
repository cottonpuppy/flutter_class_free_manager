import 'package:class_free_manager/main.dart';
import 'package:flutter/material.dart';
import '../models/record.dart';
import '../models/user.dart';

class RecordDetailPage extends StatefulWidget {
  final Record record;
  final void Function(String reviewedBy) onReviewed;
  final void Function() onDisputeSubmitted; // 质疑提交回调
  final void Function() onDisputeResolved;  // 质疑解决回调

  RecordDetailPage({
    required this.record,
    required this.onReviewed,
    required this.onDisputeSubmitted, // 传递质疑提交的回调
    required this.onDisputeResolved,   // 传递质疑解决的回调
  });

  @override
  _RecordDetailPageState createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  final TextEditingController _disputeController = TextEditingController();
  final TextEditingController _responseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAndLockRecord();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Item: ${widget.record.item}', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text('Amount: \$${widget.record.amount}', style: TextStyle(fontSize: 18)),
              if (widget.record.reviewedBy != null)
                Text('Reviewed By: ${widget.record.reviewedBy}', style: TextStyle(color: Colors.blue)),
              if (widget.record.isLocked)
                Text('Status: Confirmed', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              if (widget.record.productImage != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Product Image:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Image.file(widget.record.productImage!, height: 200),
                  ],
                ),
              if (widget.record.receiptImage != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text('Receipt Image:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Image.file(widget.record.receiptImage!, height: 200),
                  ],
                ),
              if (widget.record.disputes.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text('Disputes:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...widget.record.disputes.map((d) => Text('• $d')).toList(),
                  ],
                ),
              if (widget.record.responses.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text('Responses:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...widget.record.responses.map((r) => Text('• $r')).toList(),
                  ],
                ),
              if (!widget.record.isLocked && currentUser.role == UserRole.Student)
                ElevatedButton(
                  onPressed: _showDisputeDialog,
                  child: Text('Submit Dispute'),
                ),
              if (!widget.record.isLocked && currentUser.role == UserRole.Student)
                ElevatedButton(
                  onPressed: _confirmRecord,
                  child: Text('Confirm Record (${widget.record.confirmations}/82)'),
                ),
              if (currentUser.role == UserRole.Monitor && !widget.record.isLocked)
                Column(
                  children: [
                    TextField(
                      controller: _responseController,
                      decoration: InputDecoration(labelText: 'Enter Response'),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _submitResponse,
                      child: Text('Submit Response'),
                    ),
                  ],
                ),
              if (currentUser.role == UserRole.Teacher)
                ElevatedButton(
                  onPressed: widget.record.reviewedBy != null
                      ? null
                      : () {
                          widget.onReviewed(currentUser.name);
                          setState(() {
                            widget.record.reviewedBy = currentUser.name;
                          });
                        },
                  child: Text(widget.record.reviewedBy != null ? 'Reviewed' : 'Review Record'),
                ),
              // 显示质疑状态
              if (widget.record.isDisputed && !widget.record.isResolved)
                Text(
                  'Dispute: Unresolved',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              if (!widget.record.isDisputed && widget.record.isResolved)
                Text(
                  'Dispute: Resolved',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkAndLockRecord() {
    if (!widget.record.isLocked &&
        (widget.record.confirmations > 41 || DateTime.now().difference(widget.record.date).inDays > 7)) {
      setState(() {
        widget.record.isLocked = true;
      });
    }
  }

  void _showDisputeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Submit Dispute'),
          content: TextField(
            controller: _disputeController,
            decoration: InputDecoration(hintText: 'Enter your dispute'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_disputeController.text.isNotEmpty) {
                  setState(() {
                    widget.record.disputes.add(_disputeController.text);
                    widget.record.isDisputed = true; // 提交质疑时设置isDisputed为true
                  });
                  widget.onDisputeSubmitted(); // 触发质疑提交回调
                  _disputeController.clear();
                }
                Navigator.of(context).pop();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _confirmRecord() {
    setState(() {
      widget.record.confirmations++;
      if (widget.record.confirmations > 41) {
        widget.record.isLocked = true;
        widget.record.isConfirmed = true;
      }
    });
  }

  void _submitResponse() {
    if (_responseController.text.isNotEmpty) {
      setState(() {
        widget.record.responses.add(_responseController.text);
        widget.record.isResolved = true; // 回复质疑时，标记为已解决
        widget.record.isDisputed = false; // 将isDisputed设为false，表示不再有争议
      });
      widget.onDisputeResolved(); // 触发质疑解决回调
    }
  }
}
