import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pass_manager/models/Password.dart';
import 'package:pass_manager/models/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'EncryptionHelper.dart';

class FirestoreService {
  final CollectionReference passwords = FirebaseFirestore.instance.collection('passwords');
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  Stream<QuerySnapshot> getPasswords() async* {
    try {
      final userSnapshot = await getLoggedInUser();
      if (userSnapshot.docs.isNotEmpty) {
        String userId = userSnapshot.docs.first.id;
        yield* passwords.where('user', isEqualTo: userId).snapshots();
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      print("Error in getPasswords stream: $e");
    }
  }

  Future<String> createPassword(String name, String username, String password) async {
    try {
      final user = await getLoggedInUser();
      if (user.docs.isNotEmpty) {
        String userId = user.docs.first.id;
        String encryptedPassword = EncryptionHelper.encrypt(password);
       await passwords.add(Password(
                name: name,
                username: username,
                password: encryptedPassword,
                user: userId)
            .toJson());
        return "Password Added";
      } else {
        return "User not found";
      }
    } catch (e) {
      return "Error: $e";
    }
  }


Future<String> updatePassword(String docID, String name, String username, String password) async {
  try {
    final user = await getLoggedInUser();
    if (user.docs.isNotEmpty) {
      String userId = user.docs.first.id;
      String encryptedPassword = EncryptionHelper.encrypt(password);

     await passwords.doc(docID).update(Password(
              name: name,
              username: username,
              password: encryptedPassword, 
              user: userId)
          .toJson());
      return "Account Updated";
    } else {
      return "User not found";
    }
  } catch (e) {
    return "Error: $e";
  }
}

  Future<String> deletePassword(String docID) async {
    try {
      await passwords.doc(docID).delete();
      return "Account Deleted";
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<QuerySnapshot> getLoggedInUser() async {
    String? userId = await _getUserId();
    if (userId != null) {
      return await users.where(FieldPath.documentId, isEqualTo: userId).get();
    } else {
      throw Exception('User ID not found');
    }
  }

  Future<String> getLoggedInName() async {
    final userSnapshot = await getLoggedInUser();
    String userId = userSnapshot.docs.first.id;
    final snapshot =
        await users.where(FieldPath.documentId, isEqualTo: userId).get();
    return snapshot.docs.first.get('name');
  }

  Future<QuerySnapshot> getUserByPhone(String telephone, String code) {
    return users
        .where('telephone', isEqualTo: telephone)
        .where('code', isEqualTo: code)
        .get();
  }

  Future<QuerySnapshot> getPasswordById(String? docID) {
    return passwords.where(FieldPath.documentId, isEqualTo: docID).get();
  }

  Future<QuerySnapshot> getUserByEmail(String email, String code) {
    return users
        .where('email', isEqualTo: email)
        .where('code', isEqualTo: code)
        .get();
  }

  Future<String> registerUser(
      String name, String email, String telephone, String code) async {
    final phoneUser = await getUserByPhone(telephone, code);
    final emailUser = await getUserByEmail(email, code);

    if (emailUser.docs.isNotEmpty || phoneUser.docs.isNotEmpty) {
      return "Email or Phone number already registered";
    } else {
      await users.add(
          User(name: name, email: email, telephone: telephone, code: code)
              .toJson());
      return "Success";
    }
  }

  Future<bool> loginUser(String emailOrPhone, String code) async {
    try {
      final emailUser = await getUserByEmail(emailOrPhone, code);
      final phoneUser = await getUserByPhone(emailOrPhone, code);

      if (emailUser.docs.isNotEmpty) {
        await _saveUserId(emailUser.docs.first.id);
        return true;
      } else if (phoneUser.docs.isNotEmpty) {
        await _saveUserId(phoneUser.docs.first.id);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }
}
