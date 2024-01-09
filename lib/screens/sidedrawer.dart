import 'dart:async';

import 'package:boredomapp/providers/userprovider.dart';
import 'package:boredomapp/screens/avatar.dart';
import 'package:boredomapp/screens/connections.dart';
import 'package:boredomapp/screens/userprofile.dart';
import 'package:boredomapp/services/logout_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';

class SideDrawer extends ConsumerStatefulWidget {
  const SideDrawer({super.key});

  @override
  ConsumerState<SideDrawer> createState() {
    return _SideDrawerState();
  }
}

class _SideDrawerState extends ConsumerState<SideDrawer> {
  final LogoutService _logoutService = LogoutService();

  late UserData userData;
  String? imagePath;
  @override
  void initState() {
    super.initState();
    // Fetch user data here
    // ref.refresh(userProvider);
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = await ref.refresh(userProvider.future);
    if (user != null) {
      setState(() {
        userData = user;
        imagePath = user.imagePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget getUserData() {
      final user = ref.refresh(userProvider);
      return user.when(
        error: (error, _) => Text('Please login again. $error'),
        loading: () => const Center(child: CircularProgressIndicator()),
        data: (data) {
          if (data == null) {
            return CircularProgressIndicator();
          }
          userData = data;

          return GestureDetector(
            onTap: () {
              // Navigate to the user profile page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(
                    user: data,
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'userImage',
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).canvasColor,
                    child: imagePath == null
                        ? CircleAvatar(
                            radius: 35,
                            backgroundImage:
                                AssetImage('assets/images/sloth.png'),
                            backgroundColor: Colors.transparent,
                          )
                        : CircleAvatar(
                            radius: 35,
                            backgroundImage: NetworkImage(imagePath!),
                            backgroundColor: Colors.transparent,
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  data!.username,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
      Navigator.of(context).pop(); // Close the drawer
      final user = ref.watch(userProvider);

      return user.when(
        error: (error, _) => Text('Please login again. $error'),
        loading: () => const Center(child: CircularProgressIndicator()),
        data: (data) {
          bool isLoggingOut =
              false; // Track whether the user is currently logging out

          return showDialog(
            context: context,
            barrierDismissible: false, // Prevent dismissing during logout
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () async =>
                    false, // Disable back button during logout
                child: AlertDialog(
                  title: const Text('Are you sure?'),
                  content:
                      const Text('''Your account & data will be deleted.'''),
                  actions: <Widget>[
                    TextButton(
                      onPressed: isLoggingOut
                          ? null // Disable the "No" button when logging out
                          : () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          // Set the flag to indicate that the user is logging out
                          isLoggingOut = true;

                          // Update the dialog to show a circular progress indicator

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );

                          // Logout service
                          Navigator.of(context).pop();

                          await _logoutService.logout(context, data!);
                          print('LoggedOut!');
                        } catch (e) {
                          print('Error during re-authentication: $e');
                          // Handle re-authentication error, e.g., show a message to the user
                        }
                      },
                      child: isLoggingOut
                          ? const CircularProgressIndicator() // Show a progress indicator instead of "Yes"
                          : const Text('Delete my account'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: getUserData(),
          ),
          ListTile(
            leading: const Icon(Icons.face),
            title: const Text('Avatar'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AvatarSelectionScreen(
                          initialSelection: userData.avatar,
                          onAvatarSelected: (selectedAvatar) async {
                            updateUserAvatarInDatabase(
                                userData.uid, selectedAvatar);
                          },
                        )),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Connections'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ConnectionsScreen(
                          userData: userData,
                        )),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Handle the Settings tap
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              // Show logout confirmation dialog
              _showLogoutConfirmationDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void updateUserAvatarInDatabase(String userID, String selectedAvatar) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .update({'avatar': selectedAvatar});

    ref.refresh(userProvider);
    final user = ref.watch(userProvider);
    user.when(
      data: (data) {
        userData = data!;
      },
      error: (error, _) {},
      loading: () {},
    );
  }
}
