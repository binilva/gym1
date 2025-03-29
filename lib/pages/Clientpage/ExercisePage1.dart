import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExercisePage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Exercise Tracker')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Exercise Tracker Page',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Track your workout routines and exercises here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Handle exercise action here
                  print('Exercise Started');
                },
                child: Text('Start Exercise'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
