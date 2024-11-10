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
  final TextEditingController _nameController = TextEditingController();
  final FirestoreService _service = FirestoreService();

  bool _isLoading = false;

  void clearControllers() {
    _usernameController.clear();
    _codeController.clear();
    _emailController.clear();
    _nameController.clear();
    _telephoneController.clear();
  }

  void openUserForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(
          child:
              Text("Add User", style: TextStyle(fontWeight: FontWeight.bold)),
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
              controller: _codeController,
            ),
          ],
        ),
        actions: [
          FloatingActionButton(
              mini: true,
              backgroundColor: Colors.amber[100],
              child: const Icon(Icons.check, color: Colors.black),
              onPressed: () => {
                    if (_service.registerUser(
                            _nameController.text,
                            _emailController.text,
                            _telephoneController.text,
                            _codeController.text) ==
                        "Success")
                      {clearControllers(), Navigator.pop(context)}
                    else
                      {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("User already registered with this email or phone number")),
                        )
                      }
                  }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Row(
                children: [
                  FloatingActionButton(
                    backgroundColor: Colors.amber[100],
                    onPressed: () => {
                      if (_service.loginUser(
                          _usernameController.text, _codeController.text) == true)
                        {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Homepage()),
                          )
                        }
                      else
                        {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("User not found or code incorrect")),
                          )
                        }
                    },
                    child: const Icon(Icons.login, color: Colors.black),
                  ),
                  const SizedBox(width: 20),
                  FloatingActionButton(
                    backgroundColor: Colors.amber[100],
                    child: const Icon(Icons.person_add, color: Colors.black),
                    onPressed: () => openUserForm(),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
