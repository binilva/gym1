import 'package:flutter/material.dart';
import 'LivePosturePage.dart'; // Import Live Posture Page

class ExercisePage1 extends StatefulWidget {
  @override
  _ExercisePage1State createState() => _ExercisePage1State();
}

class _ExercisePage1State extends State<ExercisePage1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Posture Correction')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LivePosturePage()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text('Live Posture Analysis', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}


