import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'anasayfa.dart';
import 'firebase_options.dart'; // Anasayfa widget'ını içeren dosya

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edirne Etkinlik Sayfası',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Uygulamanızın genel temasını ve stilini burada yapılandırabilirsiniz
      ),
      home: Anasayfa(), // Anasayfa widget'ını başlangıç sayfası olarak ayarla
      // Uygulamanın genel navigasyon ve tasarım ayarları
    );
  }
}
