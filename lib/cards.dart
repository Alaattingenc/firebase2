import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'etkinlik_detayi.dart';
import 'etkinlik_modeli.dart';
import 'anasayfa.dart'; // Anasayfa widget'ını içeren dosya

Widget buildEventCard(
  BuildContext context,
  double screenWidth,
  List<Event> filteredEvents,
  Function(Event) toggleFavorite,
) {
  return screenWidth > 600
      ? _buildWideEventList(context, filteredEvents, toggleFavorite)
      : _buildNarrowEventList(context, filteredEvents, toggleFavorite);
}

Widget _buildWideEventList(
  BuildContext context,
  List<Event> filteredEvents,
  Function(Event) toggleFavorite,
) {
  return ListView.builder(
    itemCount: filteredEvents.length,
    itemBuilder: (context, index) {
      Event event = filteredEvents[index];
      return _buildEventListItem(context, event, toggleFavorite);
    },
  );
}

Widget _buildNarrowEventList(
  BuildContext context,
  List<Event> filteredEvents,
  Function(Event) toggleFavorite,
) {
  return ListView.builder(
    itemCount: filteredEvents.length,
    itemBuilder: (context, index) {
      Event event = filteredEvents[index];
      return _buildEventListItem(context, event, toggleFavorite);
    },
  );
}

Widget _buildEventListItem(
    BuildContext context, Event event, Function(Event) toggleFavorite) {
  return Card(
    elevation: 5.0,
    margin: EdgeInsets.all(8.0),
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EtkinlikDetaySayfasi(event: event),
          ),
        );
      },
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: FutureBuilder(
              future: _loadImage(event.imageUrl),
              builder: (context, AsyncSnapshot<Image> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return snapshot.data!;
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  return Center(child: Text('Resim yüklenemedi'));
                }
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: ListTile(
              title: Text(event.title,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(DateFormat('dd MMMM yyyy').format(event.date as DateTime)),
              trailing: IconButton(
                icon: Icon(
                  event.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: event.isFavorite ? Colors.red : null,
                ),
                onPressed: () => toggleFavorite(event),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<Image> _loadImage(String imagePath) async {
  String imageUrl =
      await FirebaseStorage.instance.ref(imagePath).getDownloadURL();
  return Image.network(imageUrl, fit: BoxFit.cover);
}
