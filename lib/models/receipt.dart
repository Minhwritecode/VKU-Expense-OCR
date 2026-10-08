part of '../main.dart';

class Receipt {
  const Receipt({
    this.id,
    required this.merchant,
    required this.amount,
    required this.date,
    required this.category,
    this.note = '',
    this.imagePath,
    this.rawText = '',
  });

  final int? id;
  final String merchant;
  final double amount;
  final DateTime date;
  final String category;
  final String note;
  final String? imagePath;
  final String rawText;

  Receipt copyWith({
    int? id,
    String? merchant,
    double? amount,
    DateTime? date,
    String? category,
    String? note,
    String? imagePath,
    String? rawText,
  }) => Receipt(
    id: id ?? this.id,
    merchant: merchant ?? this.merchant,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    category: category ?? this.category,
    note: note ?? this.note,
    imagePath: imagePath ?? this.imagePath,
    rawText: rawText ?? this.rawText,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'merchant': merchant,
    'amount': amount,
    'date': date.toIso8601String(),
    'category': category,
    'note': note,
    'image_path': imagePath,
    'raw_text': rawText,
  };

  factory Receipt.fromMap(Map<String, Object?> map) => Receipt(
    id: map['id'] as int?,
    merchant: map['merchant'] as String,
    amount: (map['amount'] as num).toDouble(),
    date: DateTime.parse(map['date'] as String),
    category: map['category'] as String,
    note: map['note'] as String? ?? '',
    imagePath: map['image_path'] as String?,
    rawText: map['raw_text'] as String? ?? '',
  );
}
