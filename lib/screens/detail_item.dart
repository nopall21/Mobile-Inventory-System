import 'dart:io';

import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../models/transaction_model.dart';
import '../utils/database_helper.dart';
import 'add_transaction.dart';




class DetailItemScreen extends StatefulWidget {
  final Item item;

  const DetailItemScreen({Key? key, required this.item}) : super(key: key);

  @override
  _DetailItemScreenState createState() => _DetailItemScreenState();
}

class _DetailItemScreenState extends State<DetailItemScreen> {
  late Item _item;
  List<TransactionItem> _transactions = [];

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final transactionsItem =
    await DatabaseHelper.instance.getTransactionsByItemId(_item.id!);
    final updatedItem = await DatabaseHelper.instance
        .getItemById(_item.id!); // Ambil data barang terbaru

    setState(() {
      _transactions = transactionsItem;
      _item = updatedItem ?? _item; // Update informasi barang
    });
  }

  Future<void> _deleteItem() async {
    await DatabaseHelper.instance.deleteItem(_item.id!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Barang berhasil dihapus')),
    );
    Navigator.pop(
        context, true); // Mengembalikan nilai true untuk menandai perubahan
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Barang'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _deleteItem(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Image.file(
                    File(_item.imagePath),
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 16),
                  Text(
                    _item.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    _item.description,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Kategori: ${_item.category}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Harga: Rp ${_item.price.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Stok: ${_item.stock}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                  Text(
                    'Riwayat Transaksi',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  _transactions.isEmpty
                      ? Text('Belum ada riwayat transaksi')
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _transactions[index];

                      // Parse dan format tanggal
                      final parsedDate = DateTime.parse(transaction.date);
                      final formattedDate =
                          "${parsedDate.day.toString().padLeft(2, '0')}/"
                          "${parsedDate.month.toString().padLeft(2, '0')}/"
                          "${parsedDate.year}";

                      return ListTile(
                        title: Text(
                          transaction.type == 'in'
                              ? 'Barang Masuk'
                              : 'Barang Keluar',
                        ),
                        subtitle: Text(
                          'Tanggal: $formattedDate\nJumlah: ${transaction.quantity}',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTransactionScreen(item: _item),
                  ),
                );

                if (result == true) {
                  await _loadTransactions(); // Memuat ulang data transaksi
                  Navigator.pop(context, true); // Tandai ada perubahan
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // Lebar penuh
              ),
              child: Text('Tambah Riwayat Transaksi'),
            ),
          ],
        ),
      ),
    );
  }
}