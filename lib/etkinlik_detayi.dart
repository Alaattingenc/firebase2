import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'etkinlik_modeli.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class EtkinlikDetaySayfasi extends StatelessWidget {
  final Event event;

  const EtkinlikDetaySayfasi({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            FutureBuilder(
              future: _loadImage(event.imageUrl),
              builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return snapshot.data!;
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  return Text('Resim yüklenemedi');
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    DateFormat('dd MMMM yyyy', 'tr_TR').format(event.date),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  // Diğer etkinlik bilgileri...
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Image> _loadImage(String imagePath) async {
    String imageUrl = await firebase_storage.FirebaseStorage.instance
        .ref("imagePath")
        .getDownloadURL();
    return Image.network(imageUrl, fit: BoxFit.cover);
  }
}
