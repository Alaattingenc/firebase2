import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'etkinlik_modeli.dart'; // Event modelinizi buraya import edin
import 'anasayfa.dart';

class TarihSeridi extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  const TarihSeridi(
      {Key? key, required this.initialDate, required this.onDateSelected})
      : super(key: key);

  @override
  _TarihSeridiState createState() => _TarihSeridiState();
}

class _TarihSeridiState extends State<TarihSeridi> {
  late DateTime selectedDate;
  final ScrollController _dateScrollController = ScrollController();
  final int daysBefore = 2;
  final int daysAfter = 20;

  List<Event> events = []; // Etkinlik listesi

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('events').get();
    setState(() {
      events = snapshot.docs
          .map((doc) => Event.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  void filterEvents() {
    // Seçilen tarihe göre etkinlikleri filtreleyin
    List<Event> filteredEvents = events.where((event) {
      return event.date.isAtSameMomentAs(selectedDate) ||
          (event.date.isBefore(selectedDate) &&
              event.endDate.isAfter(selectedDate));
    }).toList();
    // Burada filteredEvents ile ilgili bir işlem yapabilirsiniz
  }

  // Tarih seridi widget yapısı
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime startDate = now.subtract(Duration(days: daysBefore));
    DateTime endDate = now.add(Duration(days: daysAfter));
    int totalDays = endDate.difference(startDate).inDays;

    return SizedBox(
      height: 60,
      child: ListView.builder(
        controller: _dateScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: totalDays,
        itemBuilder: (context, index) {
          DateTime date = startDate.add(Duration(days: index));
          bool isSelected = selectedDate.day == date.day &&
              selectedDate.month == date.month &&
              selectedDate.year == date.year;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
                widget.onDateSelected(date);
                filterEvents();
              });
            },
            child: Container(
              width: 70,
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.lightGreenAccent.shade400
                    : Colors.red[50],
                borderRadius: BorderRadius.circular(5),
                border: Border(
                  bottom: BorderSide(
                    color: isToday(date) ? edirneKirmizi : Colors.grey,
                    width: isToday(date) ? 6.0 : 1.0,
                  ),
                  // Diğer kenar çizgileri, soldan, sağa ve üsten ekleyebilirsiniz (isteğe bağlı)
                  //left: BorderSide(color: Colors.black, width: 1.0),
                  //right: BorderSide(color: Colors.black, width: 1.0),
                  //top: BorderSide(color: Colors.black, width: 1.0),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '${date.day}-${DateFormat('MMM', 'tr_TR').format(date)}',
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatDayOfWeek(date),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.black
                            : isWeekend(date)
                                ? Colors.red
                                : Colors.black,
                        fontWeight:
                            isWeekend(date) ? FontWeight.bold : FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  bool isToday(DateTime date) {
    DateTime now = DateTime.now();
    return date.day == now.day &&
        date.month == now.month &&
        date.year == now.year;
  }

  String _formatDayOfWeek(DateTime date) {
    var dayOfWeek = DateFormat('EEEE', 'tr_TR').format(date);
    switch (dayOfWeek) {
      case 'Pazartesi':
        return 'Pzt';
      case 'Salı':
        return 'Sal';
      case 'Çarşamba':
        return 'Çar';
      case 'Perşembe':
        return 'Per';
      case 'Cuma':
        return 'Cum';
      case 'Cumartesi':
        return 'Cmt';
      case 'Pazar':
        return 'Paz';
      default:
        return '';
    }
  }
}
