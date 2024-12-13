import 'package:compuvent/pages/dashboard/profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:compuvent/pages/dashboard/event.dart';

class HomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> _fetchFullName() async {
    try {
      String userId = _auth.currentUser!.uid;
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      String fullName = userDoc['fullName'] ?? 'Guest';
      return fullName;
    } catch (e) {
      print("Error fetching user data: $e");
      return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Computing Event", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: <Widget>[
            // Tab bar for navigation
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home), text: 'Home'),
                Tab(icon: Icon(Icons.event), text: 'EVENT'),
                Tab(icon: Icon(Icons.account_circle), text: 'Profile'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Home Page with modern design
                  FutureBuilder<String>(
                    future: _fetchFullName(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text("Failed to load user data."));
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Welcome message with user's name
                              Text(
                                "Welcome, ${snapshot.data}!",
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Card for Upcoming Events
                              Card(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: const Icon(Icons.event, color: Colors.blueAccent),
                                  title: const Text(
                                    "Upcoming Events",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: const Text("Check out the latest events happening soon."),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => EventPage()),
                                    );
                                  },
                                ),
                              ),

                              // Additional Information or Options
                              const SizedBox(height: 20),
                              const Text(
                                "Explore more features in the app to stay updated with upcoming events.",
                                style: TextStyle(fontSize: 16, color: Colors.black87),
                              ),
                              const SizedBox(height: 20),


                            ],
                          ),
                        );
                      }
                    },
                  ),
                  // EVENT Page
                  EventPage(),
                  // Profile Page
                  ProfilePage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
