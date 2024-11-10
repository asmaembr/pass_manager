// This file contains the model for the User object
class User {
  final String id;
  final String name;
  final String email;
  final String telephone;
  final String code;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.telephone,
    required this.code,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      telephone: json['telephone'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'telephone': telephone,
    'code': code,
  };
  
}