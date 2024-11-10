import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:pass_manager/pages/HomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

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
          body: const Homepage(),
        ));
  }
}
