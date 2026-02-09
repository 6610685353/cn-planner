import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Profile Page',
              style: TextStyle(
                color: Colors.lightGreen.shade900,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),

            Text(
              'this is a demo of Profile Page',
              style: TextStyle(
                color: const Color.fromARGB(255, 45, 74, 11),
                fontSize: 16,
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                debugPrint('you pressed the button');
              },
              child: Text('Profile demo Button'),
            ),
          ],
        ),
      ),
    );
  }
}
