import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pass_manager/pages/LoginPage.dart';
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

  void openPasswordForm(String? docID) async {
    if (docID != null) {
      QuerySnapshot snapshot = await service.getPasswordById(docID);

      if (snapshot.docs.isNotEmpty) {
        var passwordData = snapshot.docs.first.data() as Map<String, dynamic>;
        nameController.text = passwordData['name'] ?? '';
        usernameController.text = passwordData['username'] ?? '';
        passwordController.text = passwordData['password'] ?? '';
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text(
            docID != null ? "Edit Password" : "Add Password",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
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
            heroTag: 'confirmButton',
            child: Icon(
              docID != null ? Icons.edit : Icons.check,
              color: Colors.black,
            ),
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
            heroTag: 'cancelButton',
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
      appBar: AppBar(
          toolbarHeight: 80,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 10),
              Column(children: [
                const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_person_rounded, size: 30),
                      SizedBox(width: 10),
                      Text("Password Manager",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 30))
                    ]),
                FutureBuilder(
                    future: service.getLoggedInName(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(snapshot.data.toString());
                      } else {
                        return const Text("Loading ...");
                      }
                    })
              ]),
              IconButton(
                  iconSize: 30,
                  onPressed: () => {
                        service.logout(),
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()))
                      },
                  icon: const Icon(Icons.logout))
            ],
          ),
          backgroundColor: Colors.amber[50]),
      backgroundColor: Colors.amber[50],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber[100],
        heroTag: 'addPasswordButton',
        onPressed: () => openPasswordForm(null),
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
                            onPressed: () => openPasswordForm(docID),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => service.deletePassword(docID),
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
