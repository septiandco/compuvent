class UserModel {
  final String userId;
  final String fullName;
  final String email;

  UserModel({required this.userId, required this.fullName, required this.email});

  // Convert UserModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
    };
  }

  // Create UserModel from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'],
      fullName: map['fullName'],
      email: map['email'],
    );
  }
}
