import 'package:flutter/material.dart';

class AvatarSelectionScreen extends StatefulWidget {
  final String initialSelection;
  final Function(String) onAvatarSelected;

  const AvatarSelectionScreen({
    Key? key,
    required this.initialSelection,
    required this.onAvatarSelected,
  }) : super(key: key);

  @override
  _AvatarSelectionScreenState createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  late String selectedAvatar;

  @override
  void initState() {
    super.initState();
    selectedAvatar = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Avatar'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            buildAvatarSelection('man.png'),
            SizedBox(height: 16),
            buildAvatarSelection('woman.png'),
          ],
        ),
      ),
    );
  }

  Widget buildAvatarSelection(String avatarImage) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAvatar = avatarImage;
        });

        // Call the callback function to update the 'avatar' variable
        widget.onAvatarSelected(avatarImage);
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: selectedAvatar == avatarImage
              ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Image.asset(
            'assets/images/$avatarImage',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  // Function to return the selected avatar
  String getSelectedAvatar() {
    return selectedAvatar;
  }
}
