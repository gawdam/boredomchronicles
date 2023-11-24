import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key, required this.user});
  final user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SizedBox(
        width: double.infinity, // Set the width to take up the entire screen
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: 'userImage',
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(
                        user.imageURL), // Replace with the actual user image
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.username,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connected to: Username2',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                buildMoodSection('Today', '😊'),
                buildMoodSection('This Week', '😐'),
                buildMoodSection('This Month', '😔'),
                buildMoodSection('This Year', '😃'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMoodSection(String title, String emoji) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          emoji,
          style: const TextStyle(fontSize: 40),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
