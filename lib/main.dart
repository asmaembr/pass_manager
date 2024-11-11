import 'package:firebase_core/firebase_core.dart';
import 'package:pass_manager/pages/LoginPage.dart';
import 'package:pass_manager/services/firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:pass_manager/pages/HomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? isLoggedIn = prefs.getString('userid') != null;

  final FirestoreService service = FirestoreService();
  runApp(MainApp(
    isLoggedIn: isLoggedIn,
    service: service,
  ));
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;
  final FirestoreService service;
  const MainApp({super.key, required this.isLoggedIn, required this.service});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.amber[50],
          body: isLoggedIn ? const Homepage() : const LoginPage(),
        ));
  }
}
