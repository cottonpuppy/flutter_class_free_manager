import 'package:class_free_manager/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/class_manager.dart';
import '../models/user.dart';
import '../models/record.dart' as custom;
import 'archived_records_page.dart';
import 'record_detail_page.dart';
import 'add_record_page.dart';
import 'collect_fee_page.dart';

class RecordListPage extends StatefulWidget {
  @override
  _RecordListPageState createState() => _RecordListPageState();
}

class _RecordListPageState extends State<RecordListPage> {
  String? lastReviewedBy; // 最近验收的老师
  String _filter = "All"; // 筛选条件：All, Reviewed, Confirmed
  String _sortBy = "Date"; // 排序条件：Date, Amount

  Future<void> _sendRecordToServer(custom.Record record) async {
    final url = Uri.parse('http://192.168.127.1:8080/records'); // 替换为服务端 API 地址

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'item': record.item,
        'amount': record.amount,
        'date': record.date.toIso8601String(),
        'isReviewed': record.isReviewed,
        'isConfirmed': record.isConfirmed,
        'isDisputed': record.isDisputed,
        'isResolved': record.isResolved,
      }),
    );

    if (response.statusCode == 200) {
      print('Record successfully sent to server');
    } else {
      print('Failed to send record to server: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final classManager = Provider.of<ClassManager>(context);
    final currentClass = classManager.currentClass;
    final feeManager = currentClass.feeManager;  // 获取 FeeManager

    // 根据筛选条件过滤记录
    List<custom.Record> filteredRecords = List<custom.Record>.from(feeManager.records);

    if (_filter == "Reviewed") {
      filteredRecords = filteredRecords.where((record) => record.isReviewed || record.isConfirmed).toList();
    } else if (_filter == "Confirmed") {
      filteredRecords = filteredRecords.where((record) => record.isConfirmed).toList();
    }

    // 根据排序条件排序记录
    if (_sortBy == "Amount") {
      filteredRecords.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (_sortBy == "Date") {
      filteredRecords.sort((a, b) => b.date.compareTo(a.date));
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: currentClass.name,
              items: classManager.classes
                  .map((c) => DropdownMenuItem<String>(
                        value: c.name,
                        child: Text(c.name),
                      ))
                  .toList(),
              onChanged: (newClassName) {
                final newIndex = classManager.classes
                    .indexWhere((c) => c.name == newClassName);
                if (newIndex != -1) {
                  classManager.switchClass(newIndex);
                  setState(() {});
                }
              },
            ),
            // 显示剩余余额
            Text(
              'Remaining Balance: \$${feeManager.remainingBalance.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterSortDialog, // 打开筛选和排序对话框
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: _showRoleSelectionDialog, // 角色和用户选择功能
          ),
          IconButton(
            icon: Icon(Icons.archive),
            onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
              builder: (context) => ArchivedRecordsPage(), // Use the correct class name
            ),
          );
        },
          ),
        ],
      ),
      body: filteredRecords.isEmpty
          ? Center(child: Text('No records yet.'))
          : ListView.builder(
              itemCount: filteredRecords.length,
              itemBuilder: (context, index) {
                final record = filteredRecords[index];
                return ListTile(
                  leading: Icon(Icons.receipt_long),
                  title: Text('Item: ${record.item}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount: \$${record.amount}',
                        style: TextStyle(color: Colors.black87),
                      ),
                      Text(
                        'Date: ${record.date.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 4.0),
                      // 显示质疑状态，根据isDisputed和isResolved来判断
                      Text(
                        'Dispute Status: ${record.isDisputed ? (record.isResolved ? "Resolved" : "Unresolved") : (record.isResolved ? "Resolved" : "No Dispute")}',
                        style: TextStyle(
                          color: record.isDisputed
                              ? (record.isResolved ? Colors.green : Colors.red)
                              : (record.isResolved ? Colors.green : Colors.grey),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: record.isReviewed
                      ? Icon(Icons.check, color: Colors.blue)
                      : record.isConfirmed
                          ? Icon(Icons.check, color: Colors.green)
                          : null,
                  onTap: () async {
                    final updatedRecord = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecordDetailPage(
                          record: record,
                          onReviewed: (String reviewedBy) {
                            setState(() {
                              record.reviewedBy = reviewedBy;
                              record.isReviewed = true;
                              lastReviewedBy = reviewedBy;
                            });
                            _sendRecordToServer(record); // 数据同步到服务器
                          },
                          onDisputeSubmitted: () {
                            setState(() {
                              record.isDisputed = true; // 提交质疑
                            });
                            _sendRecordToServer(record); // 提交质疑的数据同步到服务器
                          },
                          onDisputeResolved: () {
                            setState(() {
                              record.isResolved = true; // 解决质疑
                              record.isDisputed = false; // 质疑已解决
                            });
                            _sendRecordToServer(record); // 解决质疑后的数据同步到服务器
                          },
                        ),
                      ),
                    );

                    // 如果有更新的记录，重新设置状态，确保UI刷新
                    if (updatedRecord != null) {
                      setState(() {
                        feeManager.records[index] = updatedRecord; // 更新列表中的记录
                      });
                    }
                  },
                );
              },
            ),
      floatingActionButton: currentUser.role == UserRole.Monitor
          ? FloatingActionButton(
              onPressed: () async {
                final newRecord = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddRecordPage()),
                );
                if (newRecord != null) {
                  if (feeManager.remainingBalance >= newRecord.amount) {
                    feeManager.addRecord(newRecord);  // 添加记录后，余额自动更新
                    _sendRecordToServer(newRecord);
                  } else {
                    _showInsufficientBalanceAlert();
                  }
                }
              },
              child: Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: currentUser.role != UserRole.Teacher
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CollectFeePage(
                        currentBalance: feeManager.remainingBalance,
                        onFeeCollected: (amount) {
                          feeManager.collectFee(amount);  // 收费时，余额更新
                        },
                      ),
                    ),
                  );
                },
                child: Text('Collect Class Fee'),
              ),
            )
          : null,
    );
  }

  void _showFilterSortDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter and Sort Records'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: _filter,
                items: ["All", "Reviewed", "Confirmed"].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _filter = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
              DropdownButton<String>(
                value: _sortBy,
                items: ["Date", "Amount"].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showRoleSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Your Role'),
          content: SizedBox(
            height: 300,
            width: 300,
            child: Column(
              children: [
                ListTile(
                  title: Text('Student'),
                  onTap: () {
                    _showUserSelectionDialog(UserRole.Student);
                  },
                ),
                ListTile(
                  title: Text('Monitor'),
                  onTap: () {
                    _showUserSelectionDialog(UserRole.Monitor);
                  },
                ),
                ListTile(
                  title: Text('Teacher'),
                  onTap: () {
                    _showUserSelectionDialog(UserRole.Teacher);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUserSelectionDialog(UserRole role) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final usersByRole = allUsers.where((user) => user.role == role).toList();
        return AlertDialog(
          title: Text('Select Your Name'),
          content: SizedBox(
            height: 300,
            width: 300,
            child: ListView.builder(
              itemCount: usersByRole.length,
              itemBuilder: (context, index) {
                final user = usersByRole[index];
                return ListTile(
                  title: Text(user.name),
                  onTap: () {
                    setState(() {
                      currentUser = user;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showInsufficientBalanceAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Insufficient Balance'),
          content: Text('The class fee balance is insufficient to make this purchase.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
