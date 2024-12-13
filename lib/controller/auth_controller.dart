import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compuvent/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up user
  Future<User?> signUp(String fullName, String email, String password) async {
    try {
      // Create a user with Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user ID
      String userId = userCredential.user!.uid;

      // Create a user model
      UserModel userModel = UserModel(userId: userId, fullName: fullName, email: email);

      // Store user data in Firestore
      await _firestore.collection('users').doc(userId).set(userModel.toMap());

      return userCredential.user;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  // Login user
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  // Logout user
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
