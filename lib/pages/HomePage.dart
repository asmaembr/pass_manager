import 'package:flutter/material.dart';
import 'package:pass_manager/services/firestore.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  //firestore service
  final FirestoreService service = FirestoreService();

  //text controller
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  //clear text controllers
  void clearControllers() {
    nameController.clear();
    usernameController.clear();
    passwordController.clear();
  }

  // box to add account form
  void openAccountBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Add Account"),
              backgroundColor: Colors.amber[50],
              content: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                      decoration: const InputDecoration(labelText: "Name"),
                      controller: nameController),
                  TextField(
                      decoration:
                          const InputDecoration(labelText: "Username ou email"),
                      controller: usernameController),
                  TextField(
                      decoration: const InputDecoration(labelText: "Password"),
                      controller: passwordController),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      service.createAccount(
                          nameController.text,
                          usernameController.text,
                          passwordController.text,
                          "userId");
                      clearControllers();
                      Navigator.pop(context);
                    },
                    child: const Text("Add")),
                TextButton(
                    onPressed: () {
                      clearControllers();
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber[100],
        onPressed: openAccountBox,
        child: const Icon(Icons.add),
      ),
    );
  }
}
