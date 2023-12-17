// lib/widgets/user_image_picker.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatelessWidget {
  final String imagePath;
  final Function(File?) onImageSelected;

  UserImagePicker({required this.imagePath, required this.onImageSelected});

  Future<void> openImagePickerDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  File? pickedImage = await ImagePicker()
                      .pickImage(source: ImageSource.gallery)
                      .then((pickedFile) {
                    if (pickedFile != null) {
                      return File(pickedFile.path);
                    }
                    return File(imagePath);
                  });

                  onImageSelected(pickedImage);

                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  File? pickedImage = await ImagePicker()
                      .pickImage(source: ImageSource.camera)
                      .then((pickedFile) {
                    if (pickedFile != null) {
                      return File(pickedFile.path);
                    }
                    return File(imagePath);
                  });

                  onImageSelected(pickedImage);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openImagePickerDialog(context),
      child: Hero(
        tag: 'userImage',
        child: CircleAvatar(
          radius: 60,
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          child: CircleAvatar(
            radius: 55,
            backgroundImage: FileImage(File(imagePath)),
            backgroundColor: Theme.of(context).canvasColor,
          ),
        ),
      ),
    );
  }
}
