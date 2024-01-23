import 'package:boredomapp/models/funny_words.dart';
import 'package:boredomapp/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AuthScreen();
  }
}

class _AuthScreen extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _isUsernameAvailable = true;
  bool _isLoggingIn = false;
  bool _isMounted = true;
  static double initialBoredomValue = 50.0;

  @override
  void dispose() {
    _isMounted = false; // Set to false when the widget is disposed
    super.dispose();
  }

  void _submit() async {
    if (_form.currentState?.validate() ?? false) {
      try {
        setState(() {
          _isLoggingIn = true; // Set to true when starting login
        });
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: "${_usernameController.text}@boredomapp.com",
          password: '12345678',
        );
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('sloth.png');
        String imageURL = await ref.getDownloadURL();
        UserData user = UserData(
          uid: userCredentials.user!.uid,
          username: _usernameController.text,
          boredomValue: initialBoredomValue,
          avatar: 'man.png',
          imagePath: imageURL,
          connectionState: null,
          connectedToUsername: null,
          updateTimestamp: Timestamp.now(),
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user?.uid)
            .set(user.toMap());
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${e.message}'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      } finally {
        if (_isMounted) {
          setState(() {
            _isLoggingIn = false; // Set to false after login attempt
          });
        }
      }
    }
  }

  Future<void> checkUsernameAvailability(String username) async {
    try {
      // Check if the username already exists in Firestore
      final result = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      if (result.docs.isNotEmpty) {
        setState(() {
          _isUsernameAvailable = false;
        });
      } else {
        setState(() {
          _isUsernameAvailable = true;
        });
      }
    } catch (e) {
      print('Error checking username availability: $e');
    }
  }

  Future<String> generateUniqueUsername() async {
    String username = FunnyWords.getRandomCombination();
    while (!_isUsernameAvailable) {
      // If the username is not available, generate a new one
      username = FunnyWords.getRandomCombination();
      await checkUsernameAvailability(username);
    }

    return username;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _form,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      top: 30,
                      bottom: 20,
                    ),
                    width: 300,
                    child: Image.asset('assets/images/sloth.gif'),
                  ),
                  const Text(
                    "Begin your boredom chronicles!",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  const Text(
                    "Let's get you a funky username!",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16.0),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black
                          .withOpacity(0.6), // Dark semi-transparent color
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 20),
                    child: Stack(
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            labelStyle: const TextStyle(color: Colors.white),
                            errorText: !_isUsernameAvailable
                                ? 'Oops! Username already taken!'
                                : null,
                          ),
                          onChanged: (value) async {
                            setState(() {
                              _usernameController.text = value;
                            });
                            await checkUsernameAvailability(value);
                          },
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.trim().length < 4) {
                              return 'Please enter at least 4 characters';
                            }

                            // Check if the username contains only letters and numbers
                            if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                              return 'Username can only contain letters and numbers';
                            }

                            return null;
                          },
                        ),
                        Positioned(
                          right: 8.0,
                          top: 12.0,
                          child: GestureDetector(
                            onTap: () async {
                              String newUsername =
                                  await generateUniqueUsername();
                              setState(() {
                                _usernameController.text = newUsername;
                              });
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              padding: const EdgeInsets.all(1.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.generating_tokens_outlined,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  if (!_isLoggingIn)
                    ElevatedButton.icon(
                      onPressed: () {
                        _submit();
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Begin your journey'),
                    ),
                  if (_isLoggingIn) const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
