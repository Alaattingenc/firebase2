import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'etkinlik_modeli.dart'; // Etkinlik modeli dosyanız
import 'cards.dart'; // Etkinlik kartları için kullanılan widget
import 'kategori_seridi.dart';
import 'tarih_seridi.dart';
import 'etkinlik_detayi.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:flutter/gestures.dart';

class Anasayfa extends StatefulWidget {
  const Anasayfa({super.key});

  @override
  _AnasayfaState createState() => _AnasayfaState();
}

const edirneKirmizi = Color(0xFFC41E3A);
int _currentIndex = 0;

class _AnasayfaState extends State<Anasayfa> {
  List<Event> allEvents = [];
  DateTime selectedDate = DateTime.now();
  Category selectedCategory = Category.all;
  List<Event> filteredEvents = [];
  List<Event> favoriteEvents = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    FirebaseFirestore.instance
        .collection('events')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        allEvents = snapshot.docs
            .map((doc) => Event.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
        filterEvents();
      });
    });
  }

  void filterEvents() {
    setState(() {
      filteredEvents = allEvents.where((event) {
        bool categoryFilter = selectedCategory == Category.all ||
            event.category == selectedCategory;

        bool dateFilter = event.date.isAtSameMomentAs(selectedDate) ||
            (event.date.isBefore(selectedDate) &&
                event.endDate.isAfter(selectedDate));

        return categoryFilter && dateFilter;
      }).toList();
    });
  }

  void filterByCategory(Category category) {
    setState(() {
      selectedCategory = category;
      filterEvents();
    });
  }

  void toggleFavorite(Event event) {
    setState(() {
      event.isFavorite = !event.isFavorite;
      if (event.isFavorite) {
        favoriteEvents.add(event);
      } else {
        favoriteEvents.removeWhere((e) => e.title == event.title);
      }
    });
  }

  void showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bildirim'),
          content: const Text(
            'Site hakkında görüş ve önerilerinizi, edirne.events@gmail.com adresine bildiriniz.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: 'edirne.events@gmail.com',
                  query: 'subject=Görüş ve Öneri', // E-posta konusu
                );

                // E-posta uygulamasını başlatmak için
                await canLaunch(emailLaunchUri.toString())
                    ? await launch(emailLaunchUri.toString())
                    : print("E-posta uygulaması bulunamadı.");

                Navigator.pop(context);
              },
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  void showFavorites() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.red,
              child: const Column(
                children: [
                  Text(
                    'Silmek İçin Sağa Kaydırınız.→ → →',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.0), // Aralarında bir boşluk ekledik
                  Text(
                    '← ← ← Detay Sayfası',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: FavoriteEventsWidget(favoriteEvents, toggleFavorite),
            ),
          ],
        );
      },
    );
  }

  void showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Bildirim',
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Site hakkında görüş ve önerilerinizi,',
                    style: TextStyle(fontSize: 15),
                  ),
                  GestureDetector(
                    onTap: () {
                      // You can launch the email app with the following package:
                      // launch('mailto:edirne.events@gmail.com');
                    },
                    child: Text(
                      'edirne.events@gmail.com',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue, // You can customize the color
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Text(
                    'adresine gönderiniz.',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  void searchEvents(String query) {
    showSearch(
      context: context,
      delegate: CustomSearchDelegate(allEvents, toggleFavorite),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.orange[100],
      appBar: AppBar(
        backgroundColor: edirneKirmizi,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            color: Colors.white,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Bildirim'),
                    content: RichText(
                      text: TextSpan(
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                        children: [
                          TextSpan(
                            text: '(WhatsApp)  0530 348 06 69',
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                // WhatsApp'a yönlendirme için
                                String whatsappUrl =
                                    "whatsapp://send?phone=905303480669";
                                await canLaunch(whatsappUrl)
                                    ? launch(whatsappUrl)
                                    : print("WhatsApp uygulaması yüklenmemiş.");
                              },
                          ),
                          const TextSpan(
                            text: ' numaralı telefon ile irtibata geçiniz. ',
                          ),
                          const TextSpan(
                            text: 'Etkinliğe ait bilgi ve görselleri ',
                          ),
                          TextSpan(
                            text: 'edirne.events@gmail.com',
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                // E-posta uygulamasını başlatma için
                                String emailUrl =
                                    "mailto:edirne.events@gmail.com";
                                await canLaunch(emailUrl)
                                    ? launch(emailUrl)
                                    : print("E-posta uygulaması bulunamadı.");
                              },
                          ),
                          const TextSpan(
                            text: ' adresine gönderiniz.',
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Tamam'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        title: const Text(
          'Edirne Events',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: Colors.white,
            onPressed: () {
              searchEvents('');
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          KategoriSeridi(
            selectedCategory: selectedCategory,
            onCategorySelected: (newCategory) {
              setState(() {
                selectedCategory = newCategory;
                filterEvents();
              });
            },
          ),
          TarihSeridi(
            initialDate: selectedDate,
            onDateSelected: (newDate) {
              setState(() {
                selectedDate = newDate;
                filterEvents();
              });
            },
          ),
          Expanded(
            child: filteredEvents.isEmpty
                ? const Center(
                    child: Text('Bu tarih ve kategori için etkinlik yok.'),
                  )
                : buildEventCard(
                    context, screenWidth, filteredEvents, toggleFavorite),
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(10),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.red[200],
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              if (_currentIndex == 1) {
                showFavorites();
              } else if (_currentIndex == 0) {
                showInfoDialog(context);
              }
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: 'İnfo',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favoriler',
            ),
          ],
        ),
      ),
    );
  }
}

class FavoriteEventsWidget extends StatelessWidget {
  final List<Event> favoriteEvents;
  final Function(Event) toggleFavorite;

  const FavoriteEventsWidget(this.favoriteEvents, this.toggleFavorite);

  @override
  Widget build(BuildContext context) {
    return favoriteEvents.isEmpty
        ? const Center(
            child: Text('Favori etkinlik bulunmamaktadır.'),
          )
        : ListView.builder(
            itemCount: favoriteEvents.length,
            itemBuilder: (context, index) {
              Event event = favoriteEvents[index];
              return Dismissible(
                key: Key(event.title),
                onDismissed: (direction) {
                  if (direction == DismissDirection.startToEnd) {
                    // Sola kaydırma yönlendirmesi
                    toggleFavorite(event);
                    //ScaffoldMessenger.of(context).showSnackBar(
                    //SnackBar(
                    //  content:
                    //      Text('${event.title} favorilerden kaldırıldı.'),
                    //),
                    //);
                  } else if (direction == DismissDirection.endToStart) {
                    //Sağa kaydırma yönlendirmesi
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EtkinlikDetaySayfasi(event: event),
                      ),
                    );
                  }
                },
                background: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.only(left: 16),
                  alignment: Alignment.centerLeft,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.blue,
                  padding: const EdgeInsets.only(right: 16),
                  alignment: Alignment.centerRight,
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
                child: buildEventCard(context, event, toggleFavorite),
              );
            },
          );
  }

  Widget buildEventCard(
      BuildContext context, Event event, Function(Event) toggleFavorite) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 3,
        color: Colors
            .cyan[100], // Renk belirleme (istediğiniz rengi seçebilirsiniz)

        child: Column(
          children: [
            ListTile(
              title: Text(event.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat('dd MMMM yyyy', 'tr_TR').format(event.date)),
                  Text(
                      '${event.hour.hour}:${event.hour.minute.toString().padLeft(2, '0')}'),
                  Text(event.location),
                  Text(event.ticket),
                  Text(event.participantType),
                ],
              ),
              leading: const Icon(Icons.event),
              trailing: IconButton(
                icon: Icon(
                  event.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: event.isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  toggleFavorite(event);
                },
              ),
              /*onTap: () {
                 'Kartın üzerine tıklandığında detay sayfasına git';
                Navigator.push(
                  context,
                MaterialPageRoute(
                    builder: (context) => EtkinlikDetaySayfasi(event: event),
                  ),
               );
              },*/
            ),
            /* Padding(
             padding: const EdgeInsets.all(16.0),
              child: Text(event.description),
            ),*/
          ],
        ),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final List<Event> allEvents;
  final Function(Event) toggleFavorite;

  CustomSearchDelegate(this.allEvents, this.toggleFavorite);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<Event> filteredEvents = allEvents.where((event) {
      return event.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        return buildEventCard(context, MediaQuery.of(context).size.width,
            [filteredEvents[index]], toggleFavorite);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Event> suggestedEvents = allEvents.where((event) {
      return event.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestedEvents.length,
      itemBuilder: (context, index) {
        return buildEventCard(context, MediaQuery.of(context).size.width,
            [suggestedEvents[index]], toggleFavorite);
      },
    );
  }
}
