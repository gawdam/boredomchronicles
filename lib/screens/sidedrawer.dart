import 'package:boredomapp/providers/userprovider.dart';
import 'package:boredomapp/screens/userprofile.dart';
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
  late UserData user;
  Widget getUserData() {
    final user = ref.watch(userProvider);
    return user.when(
      error: (error, _) => Text('Please login again. $error'),
      loading: () => const Center(child: CircularProgressIndicator()),
      data: (data) {
        return GestureDetector(
          onTap: () {
            // Navigate to the user profile page
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UserProfileScreen(user: data)),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'userImage',
                child: CircleAvatar(
                    radius: 30, backgroundImage: NetworkImage(data.imageURL)),
              ),
              const SizedBox(height: 20),
              Text(
                data.username,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Connections'),
            onTap: () {
              // Handle the Connections tap
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
            title: Text(
              'Logout',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
            onTap: () {
              // Handle the Logout tap
            },
          ),
        ],
      ),
    );
  }
}
