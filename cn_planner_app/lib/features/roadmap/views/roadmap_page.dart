import 'package:cn_planner_app/core/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class RoadMapPage extends StatelessWidget {
  const RoadMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Roadmap Page',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade700,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'This is a demo of Roadmap Page',
              style: TextStyle(
                fontSize: 16,
                color: const Color.fromARGB(255, 65, 57, 101),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                debugPrint('You pressed the button!');
              },
              child: Text('Roadmap demo button'),
            ),
          ],
        ),
      ),
    );
  }
}
