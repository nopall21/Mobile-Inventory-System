import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/item_model.dart';
import '../utils/database_helper.dart';


class AddItemScreen extends StatefulWidget {
  final Function() onItemAdded; //calback function for updating item list

  AddItemScreen({required this.onItemAdded});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();
  String _category = 'Makanan'; // Default category: Makanan

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      if (_image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Silakan pilih gambar untuk barang!')),
        );
        return;
      }

      final item = Item(
        name: _nameController.text,
        description: _descriptionController.text,
        category: _category,
        price: double.parse(_priceController.text),
        imagePath: _image!.path,
        stock: 0, // Default stock is 0 for new items
      );

      await DatabaseHelper.instance.insertItem(item);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Barang berhasil ditambahkan!')),
      );

      widget.onItemAdded(); // Trigger the callback to update the item list

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Barang')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Nama Barang'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama barang tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Deskripsi'),
                      maxLines: 3,
                    ),
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: InputDecoration(labelText: 'Kategori'),
                      items: [
                        DropdownMenuItem(
                          value: 'Makanan',
                          child: Text('Makanan'),
                        ),
                        DropdownMenuItem(
                          value: 'Minuman',
                          child: Text('Minuman'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _category = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kategori tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(labelText: 'Harga'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harga tidak boleh kosong';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Harga harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pilih Gambar:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                        height: 8), // Memberi jarak antara teks dan tombol
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: Icon(Icons.camera_alt),
                          label: Text('Kamera'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: Icon(Icons.photo_library),
                          label: Text('Galeri'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _image != null
                        ? Image.file(
                      _image!,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                        : Text('Belum ada gambar yang dipilih'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveItem,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(
                      double.infinity, 50), // Memastikan tombol lebar penuh
                ),
                child: Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}