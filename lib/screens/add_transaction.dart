import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../models/transaction_model.dart';
import '../utils/database_helper.dart';

class AddTransactionScreen extends StatefulWidget {
  final Item item;

  const AddTransactionScreen({Key? key, required this.item}) : super(key: key);

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _transactionType = 'in'; // Default transaction type: "Barang Masuk"
  final _quantityController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  late int _currentStock; // Stok terkini

  @override
  void initState() {
    super.initState();
    _currentStock = widget.item.stock; // Inisialisasi stok awal
    _quantityController.addListener(_updateStockPreview);
  }

  void _updateStockPreview() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    setState(() {
      if (_transactionType == 'in') {
        _currentStock = widget.item.stock + quantity;
      } else if (_transactionType == 'out') {
        _currentStock = widget.item.stock - quantity;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final quantity = int.parse(_quantityController.text);

      // Validasi stok untuk barang keluar
      if (_transactionType == 'out' && quantity > widget.item.stock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stok tidak mencukupi untuk barang keluar!')),
        );
        return;
      }

      // Simpan transaksi ke database
      final transactionItem = TransactionItem(
        itemId: widget.item.id!,
        type: _transactionType,
        quantity: quantity,
        date: _selectedDate.toIso8601String(),
      );
      await DatabaseHelper.instance.insertTransaction(transactionItem);

      // Update stok barang
      final updatedStock = _transactionType == 'in'
          ? widget.item.stock + quantity
          : widget.item.stock - quantity;
      final updatedItem = widget.item.copyWith(stock: updatedStock);
      await DatabaseHelper.instance.updateItem(updatedItem);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Riwayat transaksi berhasil disimpan!')),
      );

      Navigator.pop(context, true);
    }
  }

  String _formatSelectedDate() {
    final day = _selectedDate.day.toString().padLeft(2, '0');
    final month = _selectedDate.month.toString().padLeft(2, '0');
    final year = _selectedDate.year;

    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Riwayat Barang')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      'Barang: ${widget.item.name}',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _transactionType,
                      decoration: InputDecoration(labelText: 'Jenis Transaksi'),
                      items: [
                        DropdownMenuItem(
                          value: 'in',
                          child: Text('Barang Masuk'),
                        ),
                        DropdownMenuItem(
                          value: 'out',
                          child: Text('Barang Keluar'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _transactionType = value!;
                          _updateStockPreview();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(labelText: 'Jumlah'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jumlah tidak boleh kosong';
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return 'Jumlah harus berupa angka positif';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Stok Setelah Transaksi: $_currentStock',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Tanggal: ${_formatSelectedDate()}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Spacer(),
                        ElevatedButton(
                          onPressed: () => _selectDate(context),
                          child: Text('Pilih Tanggal'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50), // Lebar penuh
                ),
                child: Text('Simpan Transaksi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }
}