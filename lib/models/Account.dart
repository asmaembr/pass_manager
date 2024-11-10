// This file contains the Account class which is used to store the account details of the user.
import 'package:pass_manager/models/User.dart';

class Account {
  final String name;
  final String username;
  final String password;
  final User user;

  Account({
    required this.name,
    required this.username,
    required this.password,
    required this.user,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      name: json['name'],
      username: json['username'],
      password: json['password'],
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'username': username,
    'password': password,
    'user': user.toJson(),
  };

  @override
  String toString() {
    return 'Account{name: $name, username: $username, password: $password}';
  }
 
}