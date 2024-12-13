import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> _fetchUserProfile() async {
    try {
      // Get current user ID
      String userId = _auth.currentUser!.uid;

      // Fetch user document from Firestore
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(userId).get();

      // Return user data (fullName, email, etc.)
      return {
        'fullName': userDoc['fullName'] ?? 'Guest',
        'email': _auth.currentUser?.email ?? 'No email',
      };
    } catch (e) {
      print("Error fetching user data: $e");
      return {
        'fullName': 'Error',
        'email': 'Error',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Page"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Failed to load user data."));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No data available."));
          } else {
            var userProfile = snapshot.data!;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                  crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
                  children: [
                    CircleAvatar(
                      radius: 50, // Size of the profile icon
                      backgroundColor: Colors.blue, // Background color for the avatar
                      child: Icon(
                        Icons.account_circle,
                        size: 60, // Icon size
                        color: Colors.white, // Icon color
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "${userProfile['fullName']}",
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "${userProfile['email']}",
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () async {
                        await _auth.signOut();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
