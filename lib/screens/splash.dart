import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boredom meter'),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(
                top: 30,
                bottom: 20,
              ),
              width: 100,
              child: Image.asset('assets/images/sloth.gif'),
            ),
            SizedBox(
              height: 20,
            ),
            Text("Loading...")
          ],
        ),
      ),
    );
  }
}
