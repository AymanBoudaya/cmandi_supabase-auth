/*
import 'user_model.dart';

class Client extends UserModel {
  String localisation;
  int pointsDeConfiance;

  Client({
    required String id,
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phoneNumber,
    required String profilePicture,
    required this.localisation,
    required this.pointsDeConfiance,
  }) : super(
          id: id,
          firstName: firstName,
          lastName: lastName,
          username: username,
          email: email,
          phoneNumber: phoneNumber,
          profilePicture: profilePicture,
          role: 'client',
        );

  void passes() {
    // Implement passes logic
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'localisation': localisation,
      'points_de_confiance': pointsDeConfiance,
    };
  }

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      profilePicture: json['profile_picture'] ?? '',
      localisation: json['localisation'] ?? '',
      pointsDeConfiance: json['points_de_confiance'] ?? 0,
    );
  }

  static Client empty() => Client(
        id: "",
        firstName: "",
        lastName: "",
        username: "",
        email: "",
        phoneNumber: "",
        profilePicture: "",
        localisation: "",
        pointsDeConfiance: 0,
      );
}*/
