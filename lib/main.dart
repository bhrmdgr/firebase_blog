import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_blog/view/ana_sayfa.dart';
import 'package:firebase_blog/view/giris_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FirebaseAuth instance oluştur
  FirebaseAuth auth = FirebaseAuth.instance;

  // Kullanıcı oturum açmış mı kontrol et
  User? currentUser = auth.currentUser;

  // Uygulamayı yönlendirme
  Widget initialScreen = currentUser != null ? AnaSayfa() : GirisScreen();

  runApp(AnaUygulama(startWidget: initialScreen));
}

class AnaUygulama extends StatelessWidget {
  final Widget startWidget;

  const AnaUygulama({required this.startWidget, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: startWidget,
    );
  }
}
