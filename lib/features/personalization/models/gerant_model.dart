
/*
import 'package:caferesto/features/personalization/models/user_model.dart';
class Gerant extends UserModel {
  Gerant({
    required String id,
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phoneNumber,
    required String profilePicture,
  }) : super(
          id: id,
          firstName: firstName,
          lastName: lastName,
          username: username,
          email: email,
          phoneNumber: phoneNumber,
          profilePicture: profilePicture,
          role: 'gerant',
        );

  void gererCommande() {
    // Implement command management logic
  }

  @override
  Map<String, dynamic> toJson() => super.toJson();

  factory Gerant.fromJson(Map<String, dynamic> json) {
    return Gerant(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      profilePicture: json['profile_picture'] ?? '',
    );
  }

  static Gerant empty() => Gerant(
        id: "",
        firstName: "",
        lastName: "",
        username: "",
        email: "",
        phoneNumber: "",
        profilePicture: "",
      );
}
*/