import 'package:pass_manager/models/User.dart';

class Password {
  final String name;
  final String username;
  final String password;
  final User user;

  Password({
    required this.name,
    required this.username,
    required this.password,
    required this.user,
  }) ;
  
  factory Password.fromJson(Map<String, dynamic> json) {
    return Password(
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


 
}