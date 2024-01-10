// lib/widgets/user_image_picker.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final String imagePath;
  final Function(File?) onImageSelected;

  const UserImagePicker(
      {super.key, required this.imagePath, required this.onImageSelected});

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  late File _displayImage = File(widget.imagePath);

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
                    return File(widget.imagePath);
                  });

                  await widget.onImageSelected(pickedImage);
                  setState(() {
                    _displayImage = pickedImage!;
                  });

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
                    return File(widget.imagePath);
                  });

                  await widget.onImageSelected(pickedImage);
                  setState(() {
                    _displayImage = pickedImage!;
                  });
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
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Hero(
            tag: 'userImage',
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: CircleAvatar(
                radius: 55,
                backgroundImage: FileImage(_displayImage),
                backgroundColor: Theme.of(context).canvasColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
              ),
              child: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => openImagePickerDialog(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
