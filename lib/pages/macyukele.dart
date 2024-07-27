import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MacYuklemeEkrani extends StatefulWidget {
  @override
  _MacYuklemeEkraniState createState() => _MacYuklemeEkraniState();
}

class _MacYuklemeEkraniState extends State<MacYuklemeEkrani> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _macAdiController = TextEditingController();
  final TextEditingController _macSaatiController = TextEditingController();
  final TextEditingController _oranController = TextEditingController();
  final TextEditingController _tahminController = TextEditingController();
  String _sonuc = '';
  int _goster = 1;
  String _lig = '';

  Future<void> _macYukle() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestore.collection('tahminler').add({
          'macAdi': _macAdiController.text,
          'macSaati': _macSaatiController.text,
          'oran': _oranController.text,
          'tahmin': _tahminController.text,
          'sonuc': _sonuc, 
          'goster': _goster,
          'lig': _lig,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Maç başarıyla yüklendi!')),
        );

        // Clear the form fields after successful upload
        _macAdiController.clear();
        _macSaatiController.clear();
        _oranController.clear();
        _tahminController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Maç yükleme hatası: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    _macAdiController.dispose();
    _macSaatiController.dispose();
    _oranController.dispose();
    _tahminController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Maç Yükle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _macAdiController, // Use controller
                  decoration: InputDecoration(labelText: 'Maç Adı'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Maç adı boş bırakılamaz'
                      : null,
                ),
                TextFormField(
                  controller: _macSaatiController, // Use controller
                  decoration: InputDecoration(labelText: 'Maç Saati (Örn: 20:30)'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Maç saati boş bırakılamaz'
                      : null,
                ),
                TextFormField(
                  controller: _oranController, // Use controller
                  decoration: InputDecoration(labelText: 'Oran'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Oran boş bırakılamaz'
                      : null,
                ),
                TextFormField(
                  controller: _tahminController,
                  decoration: InputDecoration(labelText: 'Tahmin'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Tahmin boş bırakılamaz'
                      : null,
                ),
                // Dropdown for Sonuç (W/L/?)
                DropdownButtonFormField<String>(
                  value: _sonuc.isNotEmpty ? _sonuc : null, 
                  onChanged: (String? newValue) {
                    setState(() {
                      _sonuc = newValue!; 
                    });
                  },
                  items: ['W', 'L', '?'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Sonuç (W/L/?)'),
                  validator: (value) => value == null ? 'Sonuç seçilmeli' : null,
                ),

                TextFormField(
                  decoration: InputDecoration(labelText: 'Lig'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Lig boş bırakılamaz'
                      : null,
                  onSaved: (value) => _lig = value!,
                ),

                DropdownButtonFormField<int>(
                  value: _goster,
                  onChanged: (int? newValue) {
                    setState(() {
                      _goster = newValue!;
                    });
                  },
                  items: <int>[0, 1, 2].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value == 0
                          ? 'Geçmiş Bahisler'
                          : (value == 1 ? 'Bahisleri Göster' : 'Gösterme')),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Göster'),
                ),

                ElevatedButton(
                  onPressed: _macYukle,
                  child: Text('Maçı Yükle'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
