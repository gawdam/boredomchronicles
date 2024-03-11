import 'dart:io';
import 'package:boredomapp/models/user.dart';
import 'package:boredomapp/providers/userprovider.dart';
import 'package:boredomapp/screens/homepage.dart';
import 'package:boredomapp/services/database_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:boredomapp/widgets/user_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final DatabaseService databaseService = DatabaseService();

// ignore: must_be_immutable
class UserProfileScreen extends StatelessWidget {
  UserProfileScreen({
    Key? key,
    required this.user,
    required this.imagePath,
    required this.onProfileImageChanged,
  }) : super(key: key);
  final UserData user;
  String? imagePath;
  final Function onProfileImageChanged;

  Future<void> saveImageLocally(File image) async {
    final appDir = await getApplicationDocumentsDirectory();
    final savedImage = await image.copy('${appDir.path}/profile_pic.png');
    final imagePath = savedImage.path;

    // Save the image path in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_image_path', imagePath);
    print("path saved - $imagePath");
  }

  Future<String?> uploadImageToCloud(File image, String userId) async {
    try {
      FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('$userId.png')
          .delete();
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('user_images');

      String fileName = '$userId.png';

      UploadTask uploadTask = storageReference.child(fileName).putFile(image);
      String downloadURL = await uploadTask
          .then((taskSnapshot) => taskSnapshot.ref.getDownloadURL());

      user.imagePath = downloadURL;
      await saveUserDataToCloud(user);

      return downloadURL;
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      return null;
    }
  }

  Future<List<String>> getIconfromTimeframe(List<int> timeframe) async {
    final db = databaseService;

    try {
      final boredomValues = await Future.wait(timeframe.map((e) async {
        final value = await db.getBoredomHistoryData(e);
        return value.toDouble();
      }));

      // Logging the fetched boredom values
      print("Fetched boredom values: $boredomValues");

      return boredomValues.map((e) => getBoredomIcon(e)).toList();
    } catch (e) {
      print("Error fetching boredom values: $e");
      return []; // Return an empty list or handle the error accordingly
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
                  imagePath: imagePath,
                  onImageSelected: (File? selectedImage) async {
                    if (selectedImage != null) {
                      await saveImageLocally(selectedImage);
                      uploadImageToCloud(selectedImage, user.uid);
                      await onProfileImageChanged(selectedImage.path);
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
                RichText(
                  text: TextSpan(
                    text: user.connectedToUsername == null
                        ? 'No connection'
                        : 'Connected to: ',
                    style: const TextStyle(
                        fontFamily: 'PixelifySans', fontSize: 15),
                    children: <TextSpan>[
                      TextSpan(
                        text: user.connectedToUsername,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .secondary, // You can set your desired color
                            fontSize: 15,
                            fontFamily: 'PixelifySans'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder(
                    future: getIconfromTimeframe([1, 7, 30, 365]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != 'loading' &&
                          snapshot.hasData) {
                        return Column(
                          children: [
                            buildMoodSection(
                                'Today', snapshot.data!.elementAt(0)),
                            buildMoodSection(
                                'This Week', snapshot.data!.elementAt(1)),
                            buildMoodSection(
                                'This Month', snapshot.data!.elementAt(2)),
                            buildMoodSection(
                                'This Year', snapshot.data!.elementAt(3)),
                          ],
                        );
                      }
                      return const CircularProgressIndicator();
                    })
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
