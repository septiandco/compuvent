import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final String? imageUrl;
  final String documentId; // Add document ID to identify the event

  const EventDetailPage({
    Key? key,
    required this.title,
    required this.description,
    required this.date,
    this.imageUrl,
    required this.documentId, // Get the document ID to perform update and delete
  }) : super(key: key);

  // Function to delete the event from Firestore
  Future<void> _deleteEvent(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('events').doc(documentId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Event deleted successfully")));
      Navigator.of(context).pop(); // Navigate back after deletion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to delete event")));
    }
  }

  // Function to show a dialog for updating the event
  void _showUpdateDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController(text: title);
    final TextEditingController descriptionController = TextEditingController(text: description);
    final TextEditingController dateController = TextEditingController(text: date);
    final TextEditingController imageUrlController = TextEditingController(text: imageUrl ?? "");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update Event"),
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
                String updatedTitle = titleController.text.trim();
                String updatedDescription = descriptionController.text.trim();
                String updatedDate = dateController.text.trim();
                String updatedImageUrl = imageUrlController.text.trim();

                if (updatedTitle.isNotEmpty && updatedDescription.isNotEmpty && updatedDate.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance.collection('events').doc(documentId).update({
                      'title': updatedTitle,
                      'description': updatedDescription,
                      'date': updatedDate,
                      'image': updatedImageUrl.isNotEmpty ? updatedImageUrl : null,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Event updated successfully")));
                    Navigator.of(context).pop(); // Close dialog and return to previous screen
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to update event")));
                  }
                }
              },
              child: const Text("Update Event"),
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
        title: const Text("Event Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the event image if available
              imageUrl != null
                  ? Image.network(
                imageUrl!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              )
                  : Container(
                width: double.infinity,
                height: 250,
                color: Colors.grey[200],
                child: const Icon(
                  Icons.image,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              // Event Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Event Date
              Text(
                date,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              // Event Description
              Text(
                description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              // Buttons for update and delete
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _showUpdateDialog(context);
                    },
                    child: const Text("Update Event"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _deleteEvent(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red), // Correct parameter
                    child: const Text("Delete Event"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
