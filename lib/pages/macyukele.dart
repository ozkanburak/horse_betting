import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MacYuklemeEkrani extends StatefulWidget {
  @override
  _MacYuklemeEkraniState createState() => _MacYuklemeEkraniState();
}

class _MacYuklemeEkraniState extends State<MacYuklemeEkrani> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _macAdi = '';
  String _macSaati = '';
  String _oran = '';
   String _tahmin = '';
  String _sonuc = '';

Future<void> _macYukle() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_sonuc != 'W' && _sonuc != 'L' && _sonuc != '?') { // Sonuç kontrolü
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Geçersiz sonuç. Lütfen W, L veya ? girin.')),
        );
        return;
      }
      try {
        await _firestore.collection('tahminler').add({
          'macAdi': _macAdi,
          'macSaati': _macSaati,
          'oran': _oran,
          'tahmin': _tahmin,
          'sonuc': _sonuc,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Maç başarıyla yüklendi!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Maç yükleme hatası: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Maç Yükle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Maç Adı'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Maç adı boş bırakılamaz';
                  }
                  return null;
                },
                onSaved: (value) => _macAdi = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Maç Saati (HH:mm)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Maç saati boş bırakılamaz';
                  }
                  // Saat formatı kontrolü (isteğe bağlı)
                  return null;
                },
                onSaved: (value) => _macSaati = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Oran'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Oran boş bırakılamaz';
                  }
                  // Oran formatı kontrolü (isteğe bağlı)
                  return null;
                },
                onSaved: (value) => _oran = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Tahmin'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tahmin boş bırakılamaz';
                  }
                  // Oran formatı kontrolü (isteğe bağlı)
                  return null;
                },
                onSaved: (value) => _tahmin = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Sonuç (W/L)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Sonuç boş bırakılamaz';
                  }
                  if (value.toUpperCase() != 'W' && value.toUpperCase() != 'L') {
                    return 'Geçersiz sonuç. Lütfen W veya L girin.';
                  }
                  return null;
                },
                onSaved: (value) => _sonuc = value!.toUpperCase(),
              ),
              ElevatedButton(
                onPressed: _macYukle,
                child: Text('Maçı Yükle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
