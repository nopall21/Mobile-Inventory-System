import 'package:inventoryapp/models/item_model.dart';
import 'package:inventoryapp/models/transaction_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'inventory.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        price REAL,
        category TEXT,
        imagePath TEXT,
        stock INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        itemId INTEGER,
        type TEXT,
        quantity INTEGER,
        date TEXT,
        FOREIGN KEY (itemId) REFERENCES items (id)
      )
    ''');
  }

  // CRUD methods for Item
  Future<int> insertItem(Item item) async {
    final db = await database;
    return db.insert('items', item.toMap());
  }

  Future<List<Item>> fetchItems() async {
    final db = await database;
    final maps = await db.query('items');
    return maps.map((map) => Item.fromMap(map)).toList();
  }

  Future<List<TransactionItem>> getTransactionsByItemId(int itemId) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'itemId = ?',
      whereArgs: [itemId],
      orderBy: 'date DESC',
    );
    return result.map((json) => TransactionItem.fromJson(json)).toList();
  }

  Future<void> deleteItem(int id) async {
    final db = await database;

    // Hapus semua transaksi terkait barang ini
    await db.delete(
      'transactions',
      where: 'itemId = ?',
      whereArgs: [id],
    );

    // Hapus barang
    await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertTransaction(TransactionItem transactionItem) async {
    final db = await database;
    await db.insert('transactions', transactionItem.toJson());
  }

  Future<void> updateItem(Item item) async {
    final db = await database;
    await db.update(
      'items',
      item.toJson(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<Item?> getItemById(int id) async {
    final db = await database;
    final maps = await db.query(
      'items', // Nama tabel Anda
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Item.fromMap(maps.first); // Konversi dari Map ke objek Item
    } else {
      return null; // Jika tidak ditemukan
    }
  }
}