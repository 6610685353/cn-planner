import 'package:flutter/material.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Schedule Page',
              style: TextStyle(
                color: Colors.deepOrange.shade800,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),

            Text(
              'This is demo of Schedule Page',
              style: TextStyle(
                color: const Color.fromARGB(255, 134, 56, 29),
                fontSize: 16,
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                debugPrint('You pressed the button!');
              },
              child: Text('Schedule demo Button'),
            ),
          ],
        ),
      ),
    );
  }
}
