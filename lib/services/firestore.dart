import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pass_manager/models/Account.dart';
import 'package:pass_manager/models/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreService {
  final CollectionReference passwords =
      FirebaseFirestore.instance.collection('passwords');
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  //get all accounts
  Stream<QuerySnapshot> getPasswords() {
    return Stream.fromFuture(getLoggedInUser()).asyncExpand((userSnapshot) {
      if (userSnapshot.docs.isNotEmpty) {
        String userId = userSnapshot.docs.first.id;
        return passwords
            .where('user', isEqualTo: userId)
            .orderBy('name')
            .snapshots();
      } else {
        throw Exception('User not found');
      }
    });
  }

  //Create
  String createPassword(
      String namevalue, String usernamevalue, String passwordvalue) {
    return passwords
        .add(Password(
                name: namevalue,
                username: usernamevalue,
                password: passwordvalue,
                user: getLoggedInUser() as User)
            .toJson())
        .then((value) => "Password Added")
        .toString();
  }

  //update
  String updatePassword(String docID, String namevalue, String usernamevalue,
      String passwordvalue) {
    return passwords
        .doc(docID)
        .update(Password(
                name: namevalue,
                username: usernamevalue,
                password: passwordvalue,
                user: getLoggedInUser() as User)
            .toJson())
        .then((value) => "Account Updated")
        .toString();
  }

  //delete
  String deleteAccount(String docID) {
    return passwords
        .doc(docID)
        .delete()
        .then((value) => "Account Deleted")
        .toString();
  }

  //get user by id
  Future<QuerySnapshot<Object?>> getLoggedInUser() async{
    String? userid = await _getUserId() ;
    return users.where(FieldPath.documentId, isEqualTo: userid).get();
  }

  //get user by telephone
  QuerySnapshot<Object?>  getUserByPhone(String telephone, String code) {
    return users
        .where('telephone', isEqualTo: telephone)
        .where('code', isEqualTo: code)
        .get() as QuerySnapshot<Object?>;
  }

  //get user by email
  QuerySnapshot<Object?> getUserByEmail(String email, String code) {
    return users
        .where('email', isEqualTo: email)
        .where('code', isEqualTo: code)
        .get() as QuerySnapshot<Object?>;
  }

  //register user
  String registerUser(String namevalue, String emailvalue,
      String telephonevalue, String codevalue) {
    var phoneuser = getUserByPhone(telephonevalue, codevalue);
    var emailuser = getUserByEmail(emailvalue, codevalue);
    if (emailuser.docs.isNotEmpty) {
      return "Email already registered";
    } else if (phoneuser.docs.isNotEmpty) {
      return "Phone number already registered";
    } else {
      return users
          .add(User(
                  name: namevalue,
                  email: emailvalue,
                  telephone: telephonevalue,
                  code: codevalue)
              .toJson())
          .then((value) => "Success")
          .toString();
    }
  }

  // Login using either email or phone number
  bool loginUser(String emailOrPhone, String code) {
    try {

      var emailUser = getUserByEmail(emailOrPhone, code);
      
      var phoneUser = getUserByPhone(emailOrPhone, code);

      if (emailUser.docs.isNotEmpty) {
        _saveUserId(emailUser.docs.first.id);
        print("logged in with email");
        return true;
      } else if (phoneUser.docs.isNotEmpty) {
        _saveUserId(phoneUser.docs.first.id);
        print("User logged in with phone");
        return true;
      } else {
        return false ;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Save user ID in local storage
  void _saveUserId(String userId) {
    SharedPreferences prefs =
        SharedPreferences.getInstance() as SharedPreferences;
    prefs.setString('userId', userId);
  }

  // Get user ID from local storage
  Future<String?> _getUserId() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Logout user
  void logout() {
    SharedPreferences prefs =
        SharedPreferences.getInstance() as SharedPreferences;
    prefs.remove('userId');
    print("User logged out.");
  }
}
