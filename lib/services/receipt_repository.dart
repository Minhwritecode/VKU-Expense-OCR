part of '../main.dart';

class ReceiptRepository {
  Database? _database;
  final List<Receipt> _memory = [];

  Future<Database?> get database async {
    if (_database != null) return _database;
    try {
      final folder = await getDatabasesPath();
      _database = await openDatabase(
        p.join(folder, 'ledgerly_receipts.db'),
        version: 1,
        onCreate: (db, _) => db.execute('''
        CREATE TABLE receipts(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          merchant TEXT NOT NULL,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          category TEXT NOT NULL,
          note TEXT,
          image_path TEXT,
          raw_text TEXT
        )
      '''),
      );
    } catch (_) {
      _database = null;
    }
    return _database;
  }

  Future<List<Receipt>> all() async {
    final db = await database;
    if (db == null) {
      if (_memory.isEmpty) {
        _memory.addAll(
          _seed().asMap().entries.map(
            (entry) => entry.value.copyWith(id: -(entry.key + 1)),
          ),
        );
      }
      return List.of(_memory);
    }
    final rows = await db.query('receipts', orderBy: 'date DESC, id DESC');
    if (rows.isEmpty) {
      for (final receipt in _seed()) {
        await add(receipt);
      }
      return all();
    }
    return rows.map(Receipt.fromMap).toList();
  }

  Future<Receipt> add(Receipt receipt) async {
    final db = await database;
    if (db == null) {
      final saved = receipt.copyWith(id: DateTime.now().microsecondsSinceEpoch);
      _memory.insert(0, saved);
      return saved;
    }
    final id = await db.insert('receipts', receipt.toMap()..remove('id'));
    return receipt.copyWith(id: id);
  }

  Future<void> update(Receipt receipt) async {
    final db = await database;
    if (db == null) {
      final index = _memory.indexWhere((item) => item.id == receipt.id);
      if (index >= 0) _memory[index] = receipt;
      return;
    }
    await db.update(
      'receipts',
      receipt.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [receipt.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await database;
    if (db == null) {
      _memory.removeWhere((item) => item.id == id);
      return;
    }
    await db.delete('receipts', where: 'id = ?', whereArgs: [id]);
  }

  List<Receipt> _seed() {
    final now = DateTime.now();
    return [
      Receipt(
        merchant: 'Cà phê Nhà Gỗ',
        amount: 42000,
        date: now.subtract(const Duration(hours: 3)),
        category: 'Ăn uống',
        note: 'Họp nhóm đồ án',
      ),
      Receipt(
        merchant: 'Circle K',
        amount: 78000,
        date: now.subtract(const Duration(days: 1)),
        category: 'Mua sắm',
      ),
      Receipt(
        merchant: 'Grab',
        amount: 56000,
        date: now.subtract(const Duration(days: 2)),
        category: 'Di chuyển',
      ),
      Receipt(
        merchant: 'Nhà sách Phương Nam',
        amount: 185000,
        date: now.subtract(const Duration(days: 3)),
        category: 'Học tập',
      ),
      Receipt(
        merchant: 'Căn tin VKU',
        amount: 35000,
        date: now.subtract(const Duration(days: 5)),
        category: 'Ăn uống',
      ),
      Receipt(
        merchant: 'The Coffee House',
        amount: 96000,
        date: now.subtract(const Duration(days: 6)),
        category: 'Ăn uống',
      ),
      Receipt(
        merchant: 'WinMart',
        amount: 228000,
        date: now.subtract(const Duration(days: 8)),
        category: 'Mua sắm',
      ),
    ];
  }
}

final repositoryProvider = Provider((ref) => ReceiptRepository());
