
import 'dart:io';

class Record {
  final String item;
  final double amount;
  final String verifier;
  final DateTime date;
  final File? receiptImage;
  final File? productImage;
  List<String> disputes;
  List<String> responses;
  bool isConfirmed;
  String? acceptedBy;
  bool isReviewed;
  String? reviewedBy;
  bool isLocked; // 是否锁定
  int confirmations;

  // 新增属性
  bool isDisputed; // 是否存在争议
  bool isResolved; // 是否已解决争议

  Record({
    required this.item,
    required this.amount,
    required this.verifier,
    required this.date,
    this.receiptImage,
    this.productImage,
    List<String>? disputes,
    List<String>? responses,
    this.isConfirmed = false,
    this.acceptedBy,
    this.isReviewed = false,
    this.reviewedBy,
    this.isLocked = false, // 默认值为未锁定
    this.confirmations = 0,
    this.isDisputed = false, // 默认值为无争议
    this.isResolved = false, // 默认值为未解决
  })  : disputes = disputes ?? [],
        responses = responses ?? [];

  get id => null;
        void checkAndConfirm() {
    if (confirmations >= 41) {
      isConfirmed = true;
      isLocked = true; // 锁定记录，防止进一步更改
    }
  }
}
