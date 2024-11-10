import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  
  //get all accounts
  final  CollectionReference acounts = FirebaseFirestore.instance.collection('accounts');
  //Create
  Future<void> createAccount(String name, String username, String password, String userId) async {
    return await acounts.add({
      'name': name,
      'username': username,
      'password': password,
      'userId': userId,
    }).then((value) => print("Account Added"));
  }
    //read 

  //update

  //delete


}