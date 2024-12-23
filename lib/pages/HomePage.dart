import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pass_manager/pages/LoginPage.dart';
import 'package:pass_manager/services/EncryptionHelper.dart';
import 'package:pass_manager/services/firestore.dart';
import 'dart:math';

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

//? used to map the password and to hide or unhide it 
  final Map<int, bool> _isPasswordVisibleMap = {};

  void clearControllers() {
    nameController.clear();
    usernameController.clear();
    passwordController.clear();
  }
//? generates a random password from the given caracteres 
  String generateRandomPassword() {
    int length = Random().nextInt(15) + 5;
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()-_+=<>?';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }
//* create password form with showdialog implementation 
  void openPasswordForm(String? docID) async {
    if (docID != null) {
      QuerySnapshot snapshot = await service.getPasswordById(docID);

      if (snapshot.docs.isNotEmpty) {
        var passwordData = snapshot.docs.first.data() as Map<String, dynamic>;
        nameController.text = passwordData['name'];
        usernameController.text = passwordData['username'];
        passwordController.text =
            EncryptionHelper.decrypt(passwordData['password']);
      }
    } else {
      passwordController.text = generateRandomPassword();
    }

    await showDialog(
      context: context,
      builder: (context) {
        bool isPasswordVisible = false;

        return AlertDialog(
          title: Center(
            child: Text(
              docID != null ? "Edit Password" : "Add Password",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          backgroundColor: Colors.purple[50],
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: "Name"),
                    controller: nameController,
                  ),
                  TextField(
                    decoration:
                        const InputDecoration(labelText: "Username or email"),
                    controller: usernameController,
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Password",
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              setState(() {
                                passwordController.text =
                                    generateRandomPassword();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              //? if the docID isn't null we call the update password function
              //? else we call the create password function from the service 
              onPressed: () {
                if (docID != null) {
                  service.updatePassword(
                    docID,
                    nameController.text,
                    usernameController.text,
                    passwordController.text,
                  );
                } else {
                  service.createPassword(
                    nameController.text,
                    usernameController.text,
                    passwordController.text,
                  );
                }
                clearControllers();
                Navigator.pop(context);
              },
              child: Text(
                docID != null ? "Save Changes" : "Add Password",
                style: const TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                clearControllers();
                Navigator.pop(context);
              },
              child:
                  const Text("Cancel", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
            toolbarHeight: 90,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      image: AssetImage("assets/icon.png"),
                      width: 40,
                      height: 40,
                    ),
                    Text("Password123",
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  ],
                ),
                //! customization of the home page with the personal name of the user 
                FutureBuilder(
                    future: service.getLoggedInName(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          snapshot.data.toString(),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: Color.fromRGBO(74, 20, 140, 1)),
                        );
                      } else {
                        return const Text("Loading ...");
                      }
                    }),
                    //! logout button 
                IconButton(
                    iconSize: 30,
                    onPressed: () => {
                      //! deleting data from the sharedpreferences 
                          service.logout(),
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()))
                        },
                    icon: const Icon(Icons.logout))
              ],
            ),
            backgroundColor: Colors.purple[50]),
        backgroundColor: Colors.purple[50],
        //! add password button 
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.pink[100],
          heroTag: 'addPasswordButton',
          //? the null docID to call the create function of the service
          onPressed: () => openPasswordForm(null),
          child: const Icon(Icons.add),
        ),
        //! stream builer implementation 
        //! because the snapshot of the data returned from the getpasswords  function is a Future type
        body: StreamBuilder<QuerySnapshot>(
          stream: service.getPasswords(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              //loader
              return const Center(child: CircularProgressIndicator());
            }
      
            if (snapshot.hasData) {
              List accountList = snapshot.data!.docs;
              //chacking for empty list 
              if (accountList.isEmpty) {
                return const Center(child: Text("No passwords saved"));
              }
              //! builder of the ListView
              return ListView.builder(
                itemCount: accountList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot account = accountList[index];
                  String docID = account.id;
                  Map<String, dynamic> accountData =
                      account.data() as Map<String, dynamic>;
                  String name = accountData['name'];
                  String username = accountData['username'];
                  String encryptedPassword = accountData['password'] ?? '';
                  String password = EncryptionHelper.decrypt(encryptedPassword);
      
                  bool isPasswordVisible = _isPasswordVisibleMap[index] ?? false;
      
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.purple[100],
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
                            //! modify button 
                            IconButton(
                              icon: const Icon(Icons.settings),
                              onPressed: () => openPasswordForm(docID),
                            ),
                            //! delete button
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
      ),
    );
  }
}
