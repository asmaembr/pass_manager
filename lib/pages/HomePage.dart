import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pass_manager/services/firestore.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final FirestoreService service = FirestoreService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Map to store visibility status for each password
  Map<int, bool> _isPasswordVisibleMap = {};

  void clearControllers() {
    nameController.clear();
    usernameController.clear();
    passwordController.clear();
  }

  void openPaswwordForm(String? docID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(
          child: Text("Add Password",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Colors.amber[50],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Name"),
              controller: nameController,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Username or email"),
              controller: usernameController,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Password"),
              controller: passwordController,
            ),
          ],
        ),
        actions: [
          FloatingActionButton(
            mini: true,
            backgroundColor: Colors.amber[100],
            child: Icon(docID != null ? Icons.edit : Icons.check,
                color: Colors.black),
            onPressed: () {
              if (docID != null) {
                service.updatePassword(docID, nameController.text,
                    usernameController.text, passwordController.text);
              } else {
                service.createPassword(nameController.text,
                    usernameController.text, passwordController.text);
              }
              clearControllers();
              Navigator.pop(context);
            },
          ),
          FloatingActionButton(
            mini: true,
            backgroundColor: Colors.amber[100],
            onPressed: () {
              clearControllers();
              Navigator.pop(context);
            },
            child: const Icon(Icons.close, color: Colors.black),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber[100],
        onPressed: () => openPaswwordForm(null),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getPasswords(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List accountList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: accountList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot account = accountList[index];
                String docID = account.id;
                Map<String, dynamic> accountData =
                    account.data() as Map<String, dynamic>;
                String name = accountData['name'];
                String username = accountData['username'];
                String password = accountData['password'];

                bool isPasswordVisible = _isPasswordVisibleMap[index] ?? false;

                return Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            username,
                            style: const TextStyle(fontSize: 16),
                          ),
                          Row(
                            children: [
                              Text(
                                isPasswordVisible ? password : '••••••••',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                              IconButton(
                                icon: Icon(
                                  isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisibleMap[index] =
                                        !isPasswordVisible;
                                  });
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.settings),
                            onPressed: () => openPaswwordForm(docID),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => service.deleteAccount(docID),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("data loading ... "));
          }
        },
      ),
    );
  }
}
