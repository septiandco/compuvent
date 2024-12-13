import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compuvent/pages/dashboard/eventdetail.dart';

class EventPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to fetch events from Firestore
  Future<List<Map<String, dynamic>>> _fetchEvents() async {
    try {
      QuerySnapshot eventSnapshot = await _firestore.collection('events').get();
      return eventSnapshot.docs.map((doc) {
        // Map the document data and include the documentId
        return {
          'id': doc.id, // Include the document ID
          'title': doc['title'],
          'description': doc['description'],
          'date': doc['date'],
          'image': doc['image'],
        };
      }).toList();
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }

  // Function to show a dialog to add a new event with image URL
  void _showAddEventDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    final TextEditingController imageUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add New Event"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Event Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Event Description'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Event Date'),
              ),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL (optional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                String title = titleController.text.trim();
                String description = descriptionController.text.trim();
                String date = dateController.text.trim();
                String imageUrl = imageUrlController.text.trim();

                if (title.isNotEmpty && description.isNotEmpty && date.isNotEmpty) {
                  try {
                    await _firestore.collection('events').add({
                      'title': title,
                      'description': description,
                      'date': date,
                      'image': imageUrl.isNotEmpty ? imageUrl : null,
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Event added successfully!")),
                    );
                  } catch (e) {
                    print("Error adding event: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to add event.")),
                    );
                  }
                }
              },
              child: const Text("Add Event"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EVENT Page"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Failed to load events."));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No events available."));
          } else {
            List<Map<String, dynamic>> events = snapshot.data!;

            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                var event = events[index];
                var documentId = event['id']; // Retrieve the documentId directly here

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display Image at the top
                      event['image'] != null
                          ? Image.network(
                        event['image'],
                        width: double.infinity,
                        height: 200, // Fixed height for image
                        fit: BoxFit.cover,
                      )
                          : Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Event Title
                            Text(
                              event['title'] ?? 'Untitled Event',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Event Date
                            Text(
                              event['date'] ?? 'No date available',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Navigate to event detail on tap
                      ListTile(
                        title: const Text("View Details"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetailPage(
                                title: event['title'] ?? 'Untitled Event',
                                description: event['description'] ?? 'No description available',
                                date: event['date'] ?? 'No date available',
                                imageUrl: event['image'],
                                documentId: documentId, // Pass the document ID here
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEventDialog(context);
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Event',
      ),
    );
  }
}
