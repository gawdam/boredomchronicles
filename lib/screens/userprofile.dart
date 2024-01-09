import 'dart:io';
import 'package:boredomapp/models/user.dart';
import 'package:boredomapp/providers/userprovider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:boredomapp/widgets/user_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatelessWidget {
  UserProfileScreen({Key? key, required this.user}) : super(key: key);
  final UserData user;
  String? imagePath;

  Future<void> saveImageLocally(File image) async {
    final appDir = await getApplicationDocumentsDirectory();
    final savedImage = await image.copy('${appDir.path}/profile_pic.png');
    final imagePath = savedImage.path;

    // Save the image path in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user_image_path', imagePath);
  }

  Future<String?> uploadImageToCloud(File image, String userId) async {
    try {
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('user_images');

      String fileName = '$userId.png';

      UploadTask uploadTask = storageReference.child(fileName).putFile(image);

      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      user.imagePath = downloadURL;
      await saveUserDataToCloud(user);
      return downloadURL;
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      return null;
    }
  }

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
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                UserImagePicker(
                  imagePath: user.imagePath!,
                  onImageSelected: (File? selectedImage) {
                    if (selectedImage != null) {
                      uploadImageToCloud(selectedImage, user.uid);
                      saveImageLocally(selectedImage);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  user.username,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
