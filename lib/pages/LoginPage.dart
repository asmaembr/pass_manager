import 'package:flutter/material.dart';
import 'package:pass_manager/pages/HomePage.dart';
import 'package:pass_manager/services/firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _registercodeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final FirestoreService service = FirestoreService();

  void clearControllers() {
    _usernameController.clear();
    _codeController.clear();
    _emailController.clear();
    _nameController.clear();
    _registercodeController.clear();
    _telephoneController.clear();
  }

  void openUserForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(
          child:
              Text("Register", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Colors.amber[50],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "name"),
              controller: _nameController,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "telephone"),
              controller: _telephoneController,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "email"),
              controller: _emailController,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "code confidentiel"),
              controller: _registercodeController,
              obscureText: true,
            ),
          ],
        ),
        actions: [
          FloatingActionButton(
            mini: true,
            backgroundColor: Colors.amber[100],
            child: const Icon(Icons.check, color: Colors.black),
            onPressed: () async {
              // Call registerUser asynchronously and await the result
              String result = await service.registerUser(
                _nameController.text,
                _emailController.text,
                _telephoneController.text,
                _registercodeController.text,
              );

              if (result == "Success") {
                clearControllers();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User registered successfully")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result)),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _loginUser() async {
    bool loginSuccess = await service.loginUser(
      _usernameController.text,
      _codeController.text,
    );

    if (loginSuccess) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Homepage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not found or code incorrect")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,     
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 10),
              Icon(Icons.lock_person_rounded, size: 40),
              SizedBox(width: 10),
              Text("Password Manager",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
              SizedBox(width: 10),
            ],
          ),
          backgroundColor: Colors.amber[50]),
      backgroundColor: Colors.amber[50],
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration:
                  const InputDecoration(labelText: 'telephone ou email'),
            ),
            TextField(
              controller: _codeController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'code confidentiel'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.amber[100],
                  onPressed: _loginUser,
                  heroTag: 'loginButton',
                  child: const Icon(Icons.login, color: Colors.black),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  backgroundColor: Colors.amber[100],
                  onPressed: openUserForm,
                  heroTag: 'registerButton',
                  child: const Icon(Icons.person_add, color: Colors.black),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
