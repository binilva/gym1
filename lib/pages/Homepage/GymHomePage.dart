import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../main.dart';
import 'LoginPage.dart';

class GymHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text('Gym Management System',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.indigo[600],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            const Text('Are you a Trainer or a Client?',
                style: TextStyle(fontSize: 25, color: Colors.black)),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LoginPage(isTrainer: false)),
                );
              },
              child: const Text('Client', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LoginPage(isTrainer: true)),
                );
              },
              child: const Text('Trainer', style: TextStyle(fontSize: 22)),
            ),
          ],
        ),
      ),
    );
  }
}
