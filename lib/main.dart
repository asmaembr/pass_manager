import 'package:firebase_core/firebase_core.dart';
import 'package:pass_manager/pages/LoginPage.dart';
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
  runApp(MainApp(isLoggedIn: isLoggedIn));
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn ;
  const MainApp({super.key, required this.isLoggedIn});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.amber[50],
          appBar: AppBar(
              title: const Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 10),
                  Icon(Icons.lock_person_rounded, size: 40),
                  SizedBox(width: 10),
                  Text("Password Manager",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30))
                ],
              )),
              backgroundColor: Colors.amber[50]
              ),
          body: isLoggedIn ? const Homepage() : const LoginPage(),
        ));
  }
}
