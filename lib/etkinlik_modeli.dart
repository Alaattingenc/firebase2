import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Etkinlik kategorilerini tanımlayan enum
enum Category {
  all,
  a1,
  a2,
  a3,
  a4,
  a5,
  a6,
  a7,
  a8,
  a9,
  a10,
  a11,
  a12,
  a13,
  // Diğer kategoriler...
}

// Etkinlik bilgilerini tutan model sınıfı
class Event {
  final DateTime date;
  final DateTime endDate;
  final DateTime
      hour; // Burada DateTime olarak saklanıp, sadece saati ve dakikayı kullanacağız.
  final Category category;
  final String title;
  final String imageUrl;
  final String description;
  bool isFavorite;
  final String ticket;
  final String participantType;
  final String location;

  Event({
    required this.date,
    required this.hour,
    required this.endDate,
    required this.category,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.isFavorite,
    required this.ticket,
    required this.participantType,
    required this.location,
  });

// Firestore'dan alınan verileri Event nesnesine dönüştürmek için kullanılabilir.
  factory Event.fromMap(Map<String, dynamic> data) {
    return Event(
      date: (data['date'] as Timestamp).toDate(),
      hour: (data['hour'] as Timestamp).toDate(),
      endDate: (data['endDATE'] as Timestamp).toDate(),
      category: CategoryExtension.fromString(data['category']),
      title: data['title'],
      imageUrl: data['imageUrl'] ?? "",
      description: data['description'],
      isFavorite: data['isFavorite'],
      ticket: data['ticket'],
      participantType: data['participantType'],
      location: data['location'],
    );
  }

  // Tarih ve saat bilgisini istenen formatlarda String olarak döndüren yardımcı fonksiyonlar
  String getFormattedDate() => DateFormat('dd_MM_yyyy').format(date);
  String getFormattedEndDate() => DateFormat('dd_MM_yyyy').format(endDate);
  String getFormattedHour() => DateFormat('HH_mm').format(hour);
}

// Category enum'una yardımcı fonksiyonlar ekleyen extension
extension CategoryExtension on Category {
  String get name {
    switch (this) {
      case Category.all:
        return 'Tümü';
      case Category.a1:
        return 'Yılbaşı';
      case Category.a3:
        return 'Tiyatro Sinema';
      case Category.a4:
        return 'Konser';
      case Category.a5:
        return 'Seminer Konferans';
      case Category.a6:
        return 'Eğitim        Kurs';
      case Category.a7:
        return 'Dini     Etkinlikler';
      case Category.a8:
        return 'Sergi      Gösteri';
      case Category.a9:
        return 'Gezi                 Tur';
      case Category.a10:
        return 'Spor';
      case Category.a11:
        return 'Alışveriş';
      case Category.a12:
        return 'Tanıtım';
      case Category.a13:
        return 'Nişan     Düğün';
      default:
        return '';
    }
  }

  static Category fromString(String categoryString) {
    switch (categoryString) {
      case 'Yılbaşı':
        return Category.a1;
      // Diğer string karşılıklar...
      default:
        return Category.all;
    }
  }
}
